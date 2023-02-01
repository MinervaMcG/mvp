require "rails_helper"

RSpec.describe SupportsController, type: :request do
  let(:current_user) { create :user, role: "admin" }
  let(:user) { create :user }
  let!(:talent) { create :talent, user: user }

  describe "GET #index" do
    it "returns http success" do
      get support_path(as: current_user)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #user_page" do
    it "returns http success" do
      get support_user_path(id: user.id, as: current_user)
      expect(response).to have_http_status(:success)
    end

    it "assigns @user" do
      get support_user_path(id: user.id, as: current_user)
      expect(assigns(:user)).to eq(user)
    end

    it "assigns @user_with_pictures" do
      get support_user_path(id: user.id, as: current_user)
      expect(assigns(:user_with_pictures)).not_to be_nil
    end

    it "assigns @portfolio" do
      get support_user_path(id: user.id, as: current_user)
      expect(assigns(:portfolio)).not_to be_nil
    end

    it "assigns @supporteds" do
      get support_user_path(id: user.id, as: current_user)
      expect(assigns(:supporteds)).not_to be_nil
    end

    it "assigns @total_rewards" do
      get support_user_path(id: user.id, as: current_user)
      expect(assigns(:total_rewards)).not_to be_nil
    end

    it "renders errors/404 when user not found" do
      get support_user_path(id: 0, as: current_user)
      expect(response).to render_template("errors/404")
    end
  end

  describe "GET #search" do
    it "returns http success" do
      get search_support_path(username: user.username, as: current_user)
      expect(response).to have_http_status(:success)
    end

    it "assigns @user" do
      get search_support_path(username: user.username, as: current_user)
      expect(assigns(:user)).not_to be_nil
    end

    it "returns user with matching username" do
      get search_support_path(username: user.username, as: current_user)
      expect(JSON.parse(response.body).first["username"]).to eq(user.username)
    end
  end
end
