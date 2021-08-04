Rails.application.routes.draw do
  get 'sessions/new'
  root 'static_pages#home'
  get '/help',      to: "static_pages#help"
  get '/about',     to: "static_pages#about"
  get '/contact',   to: "static_pages#contact"
  get '/signup',    to: "users#new"
  get '/login',     to: "sessions#new"
  post '/login',    to: "sessions#create"
  delete '/logout', to: "sessions#destroy"

  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]

end

# root_path -> '/'
# root_url  -> 'https://www.rspec-exercise-sho.herokuapp.com/'
# 基本的には_path書式を使い、リダイレクトの場合のみ_url書式を使う

# resources :users の内容
# HTTPリクエスト	URL	アクション	名前付きルート	    用途
# GET	    /users	      index	  users_path	          すべてのユーザーを一覧するページ
# GET	    /users/1	    show	  user_path(user)	      特定のユーザーを表示するページ
# GET	    /users/new	  new	    new_user_path	        ユーザーを新規作成するページ（ユーザー登録）
# POST	  /users	      create	users_path	          ユーザーを作成するアクション(メール送信)
# GET	    /users/1/edit	edit	  edit_user_path(user)	id=1のユーザーを編集するページ
# PATCH	  /users/1	    update	user_path(user)	      ユーザーを更新するアクション
# DELETE	/users/1	    destroy	user_path(user)	      ユーザーを削除するアクション

# resources :account_activations の内容
# GET	    /account_activation/トークン/edit	  edit	  edit_account_activation_path(token)	

# resources :password_resets の内容
# GET	  /password_resets/new	          new	    new_password_reset_path     (log in前)forgetパスワード画面の表示
# POST	/password_resets	              create  password_resets_path        forgetパスワードメール送付
# GET	  /password_resets/トークン/edit	edit	  edit_password_reset_url(token)  
# PATCH	/password_resets/トークン	      update	password_reset_url(token)

# resources :microposts の内容
# POST	  /microposts	    create	  microposts_path
# DELETE	/microposts/1	  destroy	  micropost_path(micropost)
