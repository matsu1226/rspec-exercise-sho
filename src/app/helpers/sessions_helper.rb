module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
    # sessionメソッドで作成された一時cookies => ブラウザを閉じたら期限終了
  end

  def current_user
    if session[:user_id]  # login中なら
      @current_user ||= User.find_by(id: session[:user_id])
      # @current_user = @current_user || User.find_by(id: session[:user_id])
      # 「メモ化」= メソッド呼び出しの結果を変数に保存し、次回以降の呼び出しで再利用する手法
      # @current_userに何もないときだけfind_byが実行され、無駄なDBへの読み出しがなくなる。
    end
  end
  
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
    #= !!current_user.any?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

end
