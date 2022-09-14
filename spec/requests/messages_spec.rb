require "rails_helper"

RSpec.describe "Messages", type: :request do
  let(:current_user) { create :user }

  describe "#index" do
    let(:params) { {} }

    let(:user_1) { create :user }
    let(:user_2) { create :user }
    let(:user_3) { create :user, username: "dinis" }

    let!(:chat_1) { create :chat, sender: current_user, receiver: user_1, last_message_at: 7.days.ago }
    let!(:chat_2) { create :chat, sender: user_2, receiver: current_user, last_message_at: 3.days.ago }
    let!(:chat_3) { create :chat, sender: current_user, receiver: user_3, last_message_at: 10.days.ago }

    subject(:get_messages) { get messages_path(params: params, as: current_user) }

    it "returns a successful response" do
      get_messages

      expect(response).to have_http_status(:ok)
    end

    it "returns a list of chats sorted by the last message at field" do
      get_messages

      expect(assigns(:chats)).to eq [
        {
          "id" => chat_2.id,
          "last_message_at" => chat_2.last_message_at.iso8601,
          "last_message_text" => chat_2.last_message_text,
          "receiver_id" => user_2.id,
          "receiver_last_online" => user_2.last_access_at&.iso8601,
          "receiver_messaging_disabled" => user_2.messaging_disabled,
          "receiver_profile_picture_url" => user_2.profile_picture_url,
          "receiver_ticker" => user_2.talent&.talent_token&.ticker,
          "receiver_username" => user_2.username,
          "receiver_with_talent" => user_2.talent.present?,
          "unread_messages_count" => chat_2.sender_unread_messages_count
        },
        {
          "id" => chat_1.id,
          "last_message_at" => chat_1.last_message_at.iso8601,
          "last_message_text" => chat_1.last_message_text,
          "receiver_id" => user_1.id,
          "receiver_last_online" => user_1.last_access_at&.iso8601,
          "receiver_messaging_disabled" => user_1.messaging_disabled,
          "receiver_profile_picture_url" => user_1.profile_picture_url,
          "receiver_ticker" => user_1.talent&.talent_token&.ticker,
          "receiver_username" => user_1.username,
          "receiver_with_talent" => user_1.talent.present?,
          "unread_messages_count" => chat_1.sender_unread_messages_count
        },
        {
          "id" => chat_3.id,
          "last_message_at" => chat_3.last_message_at.iso8601,
          "last_message_text" => chat_3.last_message_text,
          "receiver_id" => user_3.id,
          "receiver_last_online" => user_3.last_access_at&.iso8601,
          "receiver_messaging_disabled" => user_3.messaging_disabled,
          "receiver_profile_picture_url" => user_3.profile_picture_url,
          "receiver_ticker" => user_3.talent&.talent_token&.ticker,
          "receiver_username" => user_3.username,
          "receiver_with_talent" => user_3.talent.present?,
          "unread_messages_count" => chat_3.sender_unread_messages_count
        }
      ]
    end

    context "when pagination is requested" do
      let(:params) do
        {
          page: 2,
          per_page: 1
        }
      end

      it "paginates the records" do
        get_messages

        expect(assigns(:chats)).to eq [
          {
            "id" => chat_1.id,
            "last_message_at" => chat_1.last_message_at.iso8601,
            "last_message_text" => chat_1.last_message_text,
            "receiver_id" => user_1.id,
            "receiver_last_online" => user_1.last_access_at&.iso8601,
            "receiver_messaging_disabled" => user_1.messaging_disabled,
            "receiver_profile_picture_url" => user_1.profile_picture_url,
            "receiver_ticker" => user_1.talent&.talent_token&.ticker,
            "receiver_username" => user_1.username,
            "receiver_with_talent" => user_1.talent.present?,
            "unread_messages_count" => chat_1.sender_unread_messages_count
          }
        ]

        expect(assigns(:pagy).count).to eq 3
        expect(assigns(:pagy).page).to eq 2
        expect(assigns(:pagy).last).to eq 3
        expect(assigns(:pagy).vars[:items]).to eq "1"
      end
    end

    context "when a user is passed in the params" do
      let(:params) do
        {
          user: user_4.id
        }
      end
      let(:user_4) { create :user }
      let!(:chat_4) { create :chat, sender: current_user, receiver: user_4, last_message_at: 11.days.ago }

      it "returns a list of chats sorted by the last message at field with the user passed" do
        get_messages

        expect(assigns(:chats)).to eq [
          {
            "id" => chat_2.id,
            "last_message_at" => chat_2.last_message_at.iso8601,
            "last_message_text" => chat_2.last_message_text,
            "receiver_id" => user_2.id,
            "receiver_last_online" => user_2.last_access_at&.iso8601,
            "receiver_messaging_disabled" => user_2.messaging_disabled,
            "receiver_profile_picture_url" => user_2.profile_picture_url,
            "receiver_ticker" => user_2.talent&.talent_token&.ticker,
            "receiver_username" => user_2.username,
            "receiver_with_talent" => user_2.talent.present?,
            "unread_messages_count" => chat_2.sender_unread_messages_count
          },
          {
            "id" => chat_1.id,
            "last_message_at" => chat_1.last_message_at.iso8601,
            "last_message_text" => chat_1.last_message_text,
            "receiver_id" => user_1.id,
            "receiver_last_online" => user_1.last_access_at&.iso8601,
            "receiver_messaging_disabled" => user_1.messaging_disabled,
            "receiver_profile_picture_url" => user_1.profile_picture_url,
            "receiver_ticker" => user_1.talent&.talent_token&.ticker,
            "receiver_username" => user_1.username,
            "receiver_with_talent" => user_1.talent.present?,
            "unread_messages_count" => chat_1.sender_unread_messages_count
          },
          {
            "id" => chat_3.id,
            "last_message_at" => chat_3.last_message_at.iso8601,
            "last_message_text" => chat_3.last_message_text,
            "receiver_id" => user_3.id,
            "receiver_last_online" => user_3.last_access_at&.iso8601,
            "receiver_messaging_disabled" => user_3.messaging_disabled,
            "receiver_profile_picture_url" => user_3.profile_picture_url,
            "receiver_ticker" => user_3.talent&.talent_token&.ticker,
            "receiver_username" => user_3.username,
            "receiver_with_talent" => user_3.talent.present?,
            "unread_messages_count" => chat_3.sender_unread_messages_count
          },
          {
            "id" => chat_4.id,
            "last_message_at" => chat_4.last_message_at.iso8601,
            "last_message_text" => chat_4.last_message_text,
            "receiver_id" => user_4.id,
            "receiver_last_online" => user_4.last_access_at&.iso8601,
            "receiver_messaging_disabled" => user_4.messaging_disabled,
            "receiver_profile_picture_url" => user_4.profile_picture_url,
            "receiver_ticker" => user_4.talent&.talent_token&.ticker,
            "receiver_username" => user_4.username,
            "receiver_with_talent" => user_4.talent.present?,
            "unread_messages_count" => chat_4.sender_unread_messages_count
          }
        ]
      end
    end

    context "when a search query is passed in the params" do
      let(:params) do
        {
          q: "di"
        }
      end

      it "returns a list of chats based on search query passed" do
        get_messages

        expect(assigns(:chats)).to eq [
          {
            "id" => chat_3.id,
            "last_message_at" => chat_3.last_message_at.iso8601,
            "last_message_text" => chat_3.last_message_text,
            "receiver_id" => user_3.id,
            "receiver_last_online" => user_3.last_access_at&.iso8601,
            "receiver_messaging_disabled" => user_3.messaging_disabled,
            "receiver_profile_picture_url" => user_3.profile_picture_url,
            "receiver_ticker" => user_3.talent&.talent_token&.ticker,
            "receiver_username" => user_3.username,
            "receiver_with_talent" => user_3.talent.present?,
            "unread_messages_count" => chat_3.sender_unread_messages_count
          }
        ]
      end
    end
  end

  describe "#create" do
    let(:params) do
      {
        message: "Thanks for the support!",
        id: receiver.id
      }
    end

    let(:receiver) { create :user }

    let(:send_message_class) { Messages::Send }
    let(:send_message_instance) { instance_double(send_message_class, call: message_sent) }
    let(:message_sent) { build :message, sender: current_user, receiver: receiver, chat: chat }
    let(:chat) { create :chat, sender: current_user, receiver: receiver }

    before do
      allow(send_message_class).to receive(:new).and_return(send_message_instance)
    end

    it "initializes and calls the send message service" do
      post messages_path(params: params, as: current_user)

      expect(send_message_class).to have_received(:new)
      expect(send_message_instance).to have_received(:call).with(
        message: "Thanks for the support!",
        sender: current_user,
        receiver: receiver
      )
    end

    it "renders a json response with the messages sent" do
      post messages_path(params: params, as: current_user)

      expect(json[:message]).to eq(message_sent.to_json)
    end

    context "when the message is empty" do
      let(:params) do
        {
          message: "",
          id: receiver.id
        }
      end

      it "returns a bad request response" do
        post messages_path(params: params, as: current_user)

        expect(response).to have_http_status(:bad_request)
        expect(json).to eq({error: "Unable to create message, either the message is empty or the sender is the same as the receiver."})
      end
    end

    context "when the message is not passed" do
      let(:params) do
        {
          id: receiver.id
        }
      end

      it "returns a bad request response" do
        post messages_path(params: params, as: current_user)

        expect(response).to have_http_status(:bad_request)
        expect(json).to eq({error: "Unable to create message, either the message is empty or the sender is the same as the receiver."})
      end
    end

    context "when the receiver is not passed" do
      let(:params) do
        {
          message: "Thanks for the support!"
        }
      end

      it "returns a not found response" do
        post messages_path(params: params, as: current_user)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "#send_to_all_supporters" do
    let(:params) do
      {
        message: "Thanks for the support!"
      }
    end

    let(:messages_sent) { [build(:message, sender: current_user)] }

    it "starts a job to send the message to all user supporters" do
      post send_to_all_supporters_messages_path(params: params, as: current_user)

      expect(SendMessageToAllSupportersJob).to have_been_enqueued.with(
        current_user.id,
        "Thanks for the support!"
      )
    end

    it "renders a json response with the messages sent" do
      send_message_job = instance_double(SendMessageToAllSupportersJob, provider_job_id: "12345")
      allow(SendMessageToAllSupportersJob).to receive(:perform_later).and_return(send_message_job)

      post send_to_all_supporters_messages_path(params: params, as: current_user)

      expect(json).to eq(
        {
          job_id: "12345"
        }
      )
    end

    context "when the message is empty" do
      let(:params) { {message: ""} }

      it "returns a bad request response" do
        post send_to_all_supporters_messages_path(params: params, as: current_user)

        expect(response).to have_http_status(:bad_request)
        expect(json).to eq({error: "Unable to create message, the message is empty."})
      end
    end

    context "when params are not passed" do
      it "returns a bad request response" do
        post send_to_all_supporters_messages_path(as: current_user)

        expect(response).to have_http_status(:bad_request)
        expect(json).to eq({error: "Unable to create message, the message is empty."})
      end
    end
  end

  describe "#send_to_all_supporters_status" do
    let(:params) do
      {
        job_id: "123456"
      }
    end

    before do
      allow(Sidekiq::Status).to receive(:at).and_return(2)
      allow(Sidekiq::Status).to receive(:total).and_return(5)
      allow(Sidekiq::Status).to receive(:get).and_return(1)
    end

    it "renders a json response with the messages sent" do
      send_message_job = instance_double(SendMessageToAllSupportersJob, job_id: "12345")
      allow(SendMessageToAllSupportersJob).to receive(:perform_later).and_return(send_message_job)

      get send_to_all_supporters_status_messages_path(params: params, as: current_user)

      expect(json).to eq(
        {
          messages_sent: 2,
          messages_total: 5,
          last_receiver_id: 1
        }
      )
    end

    context "when the job id is empty" do
      let(:params) { {job_id: ""} }

      it "returns a bad request response" do
        get send_to_all_supporters_status_messages_path(params: params, as: current_user)

        expect(response).to have_http_status(:bad_request)
        expect(json).to eq({error: "Unable to check the status. Missing job id"})
      end
    end

    context "when params are not passed" do
      it "returns a bad request response" do
        get send_to_all_supporters_status_messages_path(as: current_user)

        expect(response).to have_http_status(:bad_request)
        expect(json).to eq({error: "Unable to check the status. Missing job id"})
      end
    end
  end
end
