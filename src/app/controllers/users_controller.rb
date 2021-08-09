class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :adimin_user, only: :destroy


  def index 
    # @users = User.all
    @users = User.paginate(page: params[:page])
    # path => /users?page=2 等
    # paginateではデフォルトでLIMIT=30となっている。
  end
  

  def new
    @user = User.new
  end


  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end


  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email 
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
      # log_in @user
      # flash[:success] = "Welcome to the Sample App!"
      # redirect_to @user   # user_url(@user)
    else
      render "new"  # renderはfile名
    end
  end


  def edit
    @user = User.find(params[:id])
  end


  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user   # user_url(@user)
    else
      render "edit"
    end
  end
  

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end


  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render "show_follow"
  end


  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render "show_follow"    
  end


  private
    #strong parameters
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # bofore action
    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def adimin_user
      redirect_to(root_path) unless current_user.admin?
    end

end
