module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
    # sessionメソッドで作成された一時cookies => ブラウザを閉じたら期限終了
  end

  # ユーザーのセッションを永続的にする（永続ログイン）
  def remember(user)
    user.remember   # remember_tokenをhash化したものをDBのremember_digest columnに格納
    # cookieにuser.idとuser.remember_tokenを保存
    cookies.permanent.signed[:user_id] = user.id    
    cookies.permanent[:rememner_token] = user.remember_token
  end

  def current_user
    # 1, loginしている場合
    if (user_id = session[:user_id])    # 「（user_idにsession[:user_id]を代入した結果）session[:user_id]が存在すれば」
      @current_user ||= User.find_by(id: user_id)   # ※1
    # 2, loginしていないけど、cookie(永続ログイン)情報がある場合
    elsif (user_id = cookies.signed[:user_id])  
      user = User.find_by(id: user_id)
      # 2-1, cookie(永続ログイン)情報があるuserがDBに存在 && remember_tokenが一致
      if user & user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # 渡されたユーザーがカレントユーザーであればtrue 
  def current_user?(user)
    user && user == current_user
  end
  
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
    #= !!current_user.any?
  end

  # 永続的セッションを破棄する
  def forget(user)
    # remember_digestをDBから削除
    user.forget
    # ブラウザのクッキーを削除
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしていたURLを覚えておく
  def store_location
    session[:forwarding_url]= request.original_url if request.get?
    # (https://railsguides.jp/action_controller_overview.html#request%E3%82%AA%E3%83%96%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88)
  end

end

# ※1 = @current_user = @current_user || User.find_by(id: session[:user_id])
# 「メモ化」= メソッド呼び出しの結果を変数に保存し、次回以降の呼び出しで再利用する手法
# @current_userに何もないときだけfind_byが実行され、無駄なDBへの読み出しがなくなる。