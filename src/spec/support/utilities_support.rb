# spec/support => RSpecで用いる処理を共通化
# ここではapp\helpers\application_helper.rbの処理をそのまま引用
include ApplicationHelper
include SessionsHelper

def sign_in(user, options={})
  if options[:no_capybara]
    # Capybaraを使用していない場合にもサインインする。1
    remember_token = User.new_token
    cookies[:user_id] = user.id
    cookies[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.new_token)
  else
    visit login_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
  end
end