require "rails_helper"

RSpec.describe "Follows", type: :request do
  let(:current_user) { create :user }

  describe "#create" do
    subject(:create_follow_request) { post api_v1_follows_path(params: params, as: current_user) }

    let(:params) do
      {
        user_id: following_user_id
      }
    end

    let(:following_user) { create :user }
    let(:following_user_id) { following_user.id }

    let(:create_follow_class) { Follows::Create }
    let(:create_follow_instance) { instance_double(create_follow_class, call: true) }

    before do
      allow(create_follow_class).to receive(:new).and_return(create_follow_instance)
    end

    it "returns a successful response" do
      create_follow_request

      expect(response).to have_http_status(:created)
    end

    it "initializes and calls the create follow service with the correct params" do
      create_follow_request

      aggregate_failures do
        expect(create_follow_class).to have_received(:new).with(
          following_user: following_user,
          follower_user: current_user
        )
        expect(create_follow_instance).to have_received(:call)
      end
    end

    context "when the following user does not exist" do
      let(:following_user_id) { -1 }

      it "returns a not found response" do
        create_follow_request

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the create follow service returns a creation error" do
      let(:error) { create_follow_class::CreationError.new }

      before do
        allow(create_follow_instance).to receive(:call).and_raise(error)
        allow(Rollbar).to receive(:error)
      end

      it "returns a bad request response response" do
        create_follow_request

        expect(response).to have_http_status(:bad_request)
      end

      it "raises the error to Rollbar" do
        create_follow_request

        expect(Rollbar).to have_received(:error).with(
          error,
          "Error creating follow",
          current_user_id: current_user.id,
          following_user_id: following_user_id
        )
      end
    end

    context "when the create follow service returns an already exists error" do
      let(:error) { create_follow_class::AlreadyExistsError.new }

      before do
        allow(create_follow_instance).to receive(:call).and_raise(error)
        allow(Rollbar).to receive(:error)
      end

      it "returns a conflict response response" do
        create_follow_request

        expect(response).to have_http_status(:conflict)
      end

      it "does not raise the error to Rollbar" do
        create_follow_request

        expect(Rollbar).not_to have_received(:error)
      end
    end
  end

  describe "#destroy" do
    subject(:destroy_follow_request) { delete api_v1_follows_path(params: params, as: current_user) }

    let(:params) do
      {
        user_id: following_user_id
      }
    end

    let(:following_user) { create :user }
    let(:following_user_id) { following_user.id }

    let!(:follow) { create :follow, follower: current_user, user: following_user }

    let(:destroy_follow_class) { Follows::Destroy }
    let(:destroy_follow_instance) { instance_double(destroy_follow_class, call: true) }

    before do
      allow(destroy_follow_class).to receive(:new).and_return(destroy_follow_instance)
    end

    it "returns a successful response" do
      destroy_follow_request

      expect(response).to have_http_status(:ok)
    end

    it "initializes and calls the destroy follow service with the correct params" do
      destroy_follow_request

      aggregate_failures do
        expect(destroy_follow_class).to have_received(:new).with(
          follow: follow
        )
        expect(destroy_follow_instance).to have_received(:call)
      end
    end

    context "when the following user does not exist" do
      let(:following_user_id) { -1 }

      it "returns a not found response" do
        destroy_follow_request

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the create follow service returns a destroy error" do
      let(:error) { destroy_follow_class::DestroyError.new }

      before do
        allow(destroy_follow_instance).to receive(:call).and_raise(error)
        allow(Rollbar).to receive(:error)
      end

      it "returns a bad request response response" do
        destroy_follow_request

        expect(response).to have_http_status(:bad_request)
      end

      it "raises the error to Rollbar" do
        destroy_follow_request

        expect(Rollbar).to have_received(:error).with(
          error,
          "Error destroying follow",
          follow_id: follow.id,
          current_user_id: current_user.id,
          following_user_id: following_user_id
        )
      end
    end
  end
end
