require 'rails_helper'

describe "User pages" do
  subject{ page }   # shouldの呼び出し => Capybaraのpage変数を使用

  describe "signup page" do
    before { visit signup_path }
    it { should have_content("Sign up") }
    it { should have_title(full_title("Sign up")) }
  end
end
