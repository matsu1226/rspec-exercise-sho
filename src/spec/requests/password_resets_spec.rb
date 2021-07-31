require 'rails_helper'

describe "PasswordResets" do
  subject { page }

  describe "foget_password" do
    before { visit new_password_reset_path }

    describe "page" do
      it { should have_content("Submit") } #
      it { should have_content("Email") } #
      it { should have_title(full_title("Forget password")) }
    end

    # PasswordResets#create のfalse側のtest
    describe "non-exist user" do  
      let(:activated_user) { FactoryGirl.create(:activated_user) }

      before do
        fill_in "Email", with: "non-exist@example.com"  # DBにいないemailを入力
        click_button "Submit"
      end

      it { should have_content("Email address not found") }
      it { should have_title(full_title("Sign up")) } #
      it { should have_content("Create my account") } #
    end

    # PasswordResets#create の文true側のtest
    describe "exist user" do
      let(:activated_user) { FactoryGirl.create(:activated_user) }

      before do
        fill_in "Email", with: activated_user.email
        click_button "Submit" #Failure/Error: update_attribute(:reset_digest, User.digest(reset_token))
      end
      after(:all) { ActionMailer::Base.deliveries.clear }

      it { should have_content("Email sent with password reset instructions") }
      it { should have_content("Sign up now!") }
      it { expect(ActionMailer::Base.deliveries.size).to eq 1 }
      
    end
  end

  describe "reset_password_page" do
    let(:activated_user) { FactoryGirl.create(:activated_user) }
    before { visit edit_password_reset_url(activated_user.reset_token, email: activated_user.email) }
    it { should have_title("Reset password") }
    it { should have_content("Update password") }

    # PasswordResets#update の if文true側のtest
    describe "empty password" do  
      before do
        fill_in "Password", with: ""
        fill_in "Confirmation", with: ""
        click_button "Update password"
      end

      it { should have_content("Password can't be blank") }
      it { should have_title("Reset password") }
    end

    # PasswordResets#update の if文false(else)側のtest
    describe "wrong password" do
      let(:activated_user) { FactoryGirl.create(:activated_user) }

      before do
        fill_in "Password", with: "foobar"
        fill_in "Confirmation", with: "foobaz"
        click_button "Update password"
      end

      it { should have_title("Reset password") }
    end

    # PasswordResets#update の if文elsif側(reset_password成功)のtest
    describe "succeess reset_password" do
      let(:activated_user) { FactoryGirl.create(:activated_user) }

      before do
        fill_in "Password", with: "foobarbaz"
        fill_in "Confirmation", with: "foobarbaz"
        click_button "Update password"
      end

      it { should have_content("Password has been reset.") }
      it { should have_title(activated_user.name) }
    end    
  end

end

# hiddenに値をセットする
# find('#secret_value', visible: false).set('secret!!')