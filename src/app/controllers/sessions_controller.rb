class SessionsController < ApplicationController
  # ApplicationControllerで"include SessionsHelper"を記載。
  # SessionsHelper => log_in(user), current_user,logged_in?

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      redirect_to user    # user_path(user)
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new"
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

end
