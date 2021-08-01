class PasswordResetsController < ApplicationController
  before_action :get_user,          only: [:edit, :update]
  before_action :valid_user,        only: [:edit, :update]
  before_action :check_expiration,  only: [:edit, :update]    # reset_mailの期限確認

  def new   # forget_passwordの画面表示
  end

  def create  # forget_passwordリセットのmail送信
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest   # reset_digestとreset_tokenの生成
      @user.send_password_reset_email   # reset_mailの送付
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render "new"  # PasswordResets#newへ。
    end
  end

  def edit  # mailのリンクをクリックしたときのアクション。
  end
  
  def update  # mailのリンクから遷移したreset_passwordの画面でpassword再設定
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)   # passwordが空欄でないことを確認
      render "edit"
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else                 # passwordが正しくない場合
      render "edit"
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
    
    def get_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]) )
        # params[:id]は@user.reser_token(参照:views\user_mailer\password_reset.html.erb)であるはず
        redirect_to root_url
      end
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end

end
