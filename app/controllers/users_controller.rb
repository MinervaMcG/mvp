class UsersController < ApplicationController
  before_action :set_user, only: %i[destroy edit_profile show]

  def index
    if user_params[:email].present?
      @user = User.find_by(email: user_params[:email].downcase)
    elsif user_params[:username].present?
      @user = User.find_by(username: user_params[:username])
    end

    if @user.present?
      @user.update!(nounce: SecureRandom.uuid) if @user.nounce.nil?

      render json: {id: @user.id, nounce: @user.nounce}, status: :ok
    else
      render json: {error: "Couldn't find the user for that email or username"}, status: :not_found
    end
  end

  def create
    if !verify_captcha
      render json: {error: "We were unable to validate your captcha.", field: "captcha"}, status: :conflict
    elsif !User.valid_username?(user_params[:username])
      render json: {error: "Invalid username.", field: "username"}, status: :conflict
    elsif !User.valid_email?(user_params[:email])
      render json: {error: "Email is not valid.", field: "email"}, status: :conflict
    else
      service = Users::Create.new
      @result = service.call(
        email: user_params[:email],
        username: user_params[:username],
        password: user_params[:password],
        invite_code: user_params[:code],
        theme_preference: user_params[:theme_preference],
        legal_first_name: user_params[:legal_first_name],
        legal_last_name: user_params[:legal_last_name]
      )

      if @result[:success]
        UserMailer.with(user_id: @result[:user].id).send_sign_up_email.deliver_later(wait: 5.seconds)

        render json: @result[:user], status: :created
      else
        render json: @result, status: :conflict
      end
    end
  end

  def edit_profile
    if @user.id != current_acting_user.id
      redirect_to root_url
    end

    @talent = @user.talent
  end

  def send_confirmation_email
    User.find_by!(id: params[:user_id]).update(email_confirmation_token: Clearance::Token.new)

    UserMailer.with(user_id: params[:user_id]).send_sign_up_email.deliver_later

    render json: {id: params[:user_id]}, status: :ok
  end

  def destroy
    return redirect_to root_url unless @user == current_acting_user

    if @user.valid_delete_account_token?(params[:token])
      result = DestroyUser.new(user_id: @user.id).call
      return redirect_to root_url, flash: {success: "Account deleted"} if result

      redirect_to edit_profile_path(tab: "Settings", username: @user.username), flash: {error: "Unable to delete account"}
    else
      redirect_to edit_profile_path(tab: "Settings", username: @user.username), flash: {error: "Invalid token"}
    end
  end

  private

  def set_user
    @user = User.find_by!("username=? or wallet_id=? or ens_domain=?", params[:username], params[:username].downcase, params[:username])
  end

  def user_params
    params.permit(:email, :username, :password, :code, :captcha, :mode, :theme_preference, :legal_first_name, :legal_last_name)
  end

  def verify_captcha
    request = Faraday.post("https://www.google.com/recaptcha/api/siteverify",
      {
        secret: ENV["RECAPTCHA_SECRET_KEY"],
        response: user_params[:captcha]
      },
      {"Content-Type": "application/x-www-form-urlencoded"})

    result = JSON.parse(request.body)
    result["success"]
  end

  def should_see_talent_page?(talent)
    admin?(current_user) || talent_owner?(talent, current_user) || talent.user.public_displayable?
  end

  def admin?(user)
    user&.admin?
  end

  def talent_owner?(talent, user)
    user && user.id == talent&.user_id
  end
end
