Rails.application.routes.draw do
  root 'static_pages#home'
  get '/signup',  to: "users#new"
  get '/help',    to: "static_pages#help"
  get '/about',   to: "static_pages#about"
  get '/contact', to: "static_pages#contact"

end

# root_path -> '/'
# root_url  -> 'https://www.rspec-exercise-sho.herokuapp.com/'
# 基本的には_path書式を使い、リダイレクトの場合のみ_url書式を使う
