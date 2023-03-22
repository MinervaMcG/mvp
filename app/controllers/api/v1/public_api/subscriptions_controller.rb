class API::V1::PublicAPI::SubscriptionsController < API::V1::PublicAPI::APIController
  before_action :internal_only, only: [:create, :destroy]

  def subscribers
    return not_found unless user

    pagy, subscribers = pagy_uuid_cursor(
      user.subscribers,
      before: cursor,
      items: per_page,
      order: {created_at: :desc, uuid: :desc}
    )

    response_body = {
      subscribers: API::TalentBlueprint.render_as_json(subscribers, view: :normal),
      pagination: {
        total: user.subscribers.count,
        cursor: pagy.has_more? ? subscribers.last.uuid : nil
      }
    }
    log_request(response_body, :ok)

    render json: response_body, status: :ok
  end

  def subscribing
    return not_found unless user

    pagy, subscribing = pagy_uuid_cursor(
      user.users_subscribing,
      before: cursor,
      items: per_page,
      order: {created_at: :desc, uuid: :desc}
    )

    response_body = {
      subscribing: API::TalentBlueprint.render_as_json(subscribing, view: :normal),
      pagination: {
        total: user.users_subscribing.count,
        cursor: pagy.has_more? ? subscribing.last.uuid : nil
      }
    }
    log_request(response_body, :ok)

    render json: response_body, status: :ok
  end

  def create
    subscriber_user = user || current_user
    return not_found unless subscriber_user

    Subscriptions::Create.new(subscriber_user: subscriber_user, subscribing_user: subscribing_user).call

    render json: {success: "Subscribe successfully created."}, status: :created
  rescue Subscriptions::Create::AlreadyExistsError
    render json: {error: "Already subscribing."}, status: :conflict
  rescue Subscriptions::Create::CreationError => error
    Rollbar.error(error, "Error creating subscription", subscriber_user_id: subscriber_user.id, subscribing_user_id: subscribing_user.id)
    render json: {error: "Unable to create subscription."}, status: :bad_request
  end

  def destroy
    subscriber_user = user || current_user
    return not_found unless subscriber_user

    subscription = Subscription.find_by!(user: subscribing_user, subscriber: subscriber_user)

    Subscriptions::Destroy.new(subscription: subscription).call

    render json: {success: "Subscription successfully removed."}, status: :ok
  rescue Subscriptions::Destroy::DestroyError => error
    Rollbar.error(error, "Error destroying subscription", subscriber_user_id: subscriber_user.id, subscribing_user_id: subscribing_user.id, subscription_id: subscription.id)
    render json: {error: "Unable to remove subscription."}, status: :bad_request
  end

  private

  def subscription_params
    params.permit(:talent_id)
  end

  def subscribing_user
    @subscribing_user ||= User.find_by!("uuid::text = :id OR wallet_id = :id OR username = :id", id: subscription_params[:talent_id])
  end

  def user
    @user ||= User.find_by("uuid::text = :id OR wallet_id = :id OR username = :id", id: params[:id])
  end
end