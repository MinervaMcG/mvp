class SupportsController < ApplicationController
  def show
  end

  def user_page
    @user = User.find(params[:id])
    @user_with_pictures = UserBlueprint.render_as_json(@user, view: :with_pictures)
    @portfolio = TalentSupporter.where(supporter_wallet_id: @user.wallet_id)
    @supporteds = @user.portfolio
    @total_rewards = Reward
      .where(user_id: @user.id)
      .sum(:amount)
  rescue ActiveRecord::RecordNotFound
    format.html { render "errors/404", status: :not_found }
  end

  def search
    @user = User
      .where("username LIKE ?", "%#{params[:username]}%")
    render json: UserBlueprint.render_as_json(@user, view: :with_pictures), status: :ok
  end
end
