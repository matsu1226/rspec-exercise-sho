class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    # @user = User.new(params[:user]) => マスアサインメント脆弱性
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user   # user_url(@user)
    else
      render "new"  # renderはfile名
    end
  end

  private
    #strong parameters
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
