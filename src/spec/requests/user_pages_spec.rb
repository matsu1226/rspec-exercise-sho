require 'rails_helper'

describe "User pages" do
  subject{ page }   # shouldの呼び出し => Capybaraのpage変数を使用

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }    # user dataの作成
    before { visit user_path(user) }
    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end

  describe "signup page" do
    before { visit signup_path }
    it { should have_content("Sign up") }
    it { should have_title(full_title("Sign up")) }
  end

  describe "signup" do
    before { visit signup_path }
    let(:submit) { "Create my account" }

    describe "with invalid infomation" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count) 
        # { click_button "..."}の前後でUser.countを確認
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end
      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
    end

  end
end
