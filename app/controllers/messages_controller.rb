class MessagesController < ApplicationController
  before_action :prevent_user_impersonation

  PER_PAGE = 10

  def index
    chats = Chat.of_user(current_user)

    if user
      user_chat = Chat.between(current_user, user)
      chats = chats.or(Chat.where(id: user_chat&.id))
    end

    if search_query.present?
      chats = chats.joins("left join users on users.id = chats.receiver_id or users.id = chats.sender_id")
        .where("users.username ILIKE :query", query: "#{search_query}%")
    end

    chats = chats.includes(
      sender: [
        {
          talent: :talent_token
        }
      ],
      receiver: [
        {
          talent: :talent_token
        }
      ]
    )

    chats = search_query.present? ? chats.order("users.username ASC, chats.last_message_at DESC") : chats.order("chats.last_message_at DESC")

    @pagy, chats = pagy(chats, items: per_page)
    @chats = ChatBlueprint.render_as_json(chats, view: :normal, current_user: current_user)

    respond_to do |format|
      format.html
      format.json {
        render(
          json: {
            chats: @chats,
            pagination: {
              totalItems: @pagy.count,
              currentPage: @pagy.page,
              lastPage: @pagy.last,
              recordsPerPage: @pagy.vars[:items]
            }
          },
          status: :ok
        )
      }
    end
  end

  def show
    # required for frontend show
    @sender = current_user

    sent = Message.where(sender_id: current_user.id, receiver_id: receiver.id)
    received = Message.where(sender_id: receiver.id, receiver_id: current_user.id)
    @messages = sent.or(received).order(:created_at)
    received.update_all(is_read: true)
    chat = Chat.between(current_user, receiver)

    chat&.mark_as_read!(current_user)

    @chat = chat ? ChatBlueprint.render_as_json(chat, view: :normal, current_user: current_user) : nil
    @chat_id = chat&.id

    render json: {
      readChat: @chat,
      messages: @messages.map(&:to_json),
      chat_id: @chat_id,
      current_user_id: @sender.id,
      lastOnline: receiver.last_access_at,
      profilePictureUrl: receiver.profile_picture_url,
      username: receiver.username
    }
  end

  def create
    if message_params[:message].blank? || current_user.id == receiver.id
      return render json: {
        error: "Unable to create message, either the message is empty or the sender is the same as the receiver."
      }, status: :bad_request
    end

    if receiver.messaging_disabled?
      return render json: {
        error: "Unable to create a message, the receiver has messaging disabled."
      }, status: :bad_request
    end

    service = Messages::Send.new
    message = service.call(
      sender: current_user,
      receiver: receiver,
      message: message_params[:message]
    )

    chat = message.chat

    render json: {
      message: message.to_json,
      chat: ChatBlueprint.render_as_json(chat, view: :normal, current_user: current_user)
    }
  end

  def send_to_all_supporters
    if message_params[:message].blank?
      return render json: {
        error: "Unable to create message, the message is empty."
      }, status: :bad_request
    end

    job = SendMessageToAllSupportersJob.perform_later(current_acting_user.id, message_params[:message])

    render json: {job_id: job.provider_job_id}
  end

  def send_to_all_supporters_status
    if job_id.blank?
      return render json: {
        error: "Unable to check the status. Missing job id"
      }, status: :bad_request
    end

    render json: {
      messages_sent: Sidekiq::Status.at(job_id),
      messages_total: Sidekiq::Status.total(job_id),
      last_receiver_id: Sidekiq::Status.get(job_id, :last_receiver_id)
    }
  end

  private

  def receiver
    @receiver ||= User.find(params[:id])
  end

  def message_params
    params.permit(:message)
  end

  def user
    @user ||= User.find_by(id: params[:user])
  end

  def job_id
    @job_id ||= params[:job_id]
  end

  def per_page
    params[:per_page] || PER_PAGE
  end

  def search_query
    params[:q]
  end
end
