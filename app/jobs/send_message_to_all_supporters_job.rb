class SendMessageToAllSupportersJob < ApplicationJob
  queue_as :default
  include Sidekiq::Status::Worker

  def perform(sender_id, message)
    sender = User.find(sender_id)
    supporters = sender.supporters(including_self: false)

    total supporters.count
    at 0

    supporters.find_each.with_index do |supporter, index|
      created_message = send_message_service.call(
        message: message,
        sender: sender,
        receiver: supporter,
        sent_to_supporters: true
      )

      store last_receiver_username: created_message.receiver.username
      at index + 1
    end
  end

  private

  def send_message_service
    @send_message_service ||= Messages::Send.new
  end
end
