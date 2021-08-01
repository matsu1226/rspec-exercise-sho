require 'rails_helper'

describe "Authentication" do
  subject { page }

  describe "login page" do
    before { visit login_path }

    it { should have_content("Log in") }
    it { should have_title("Log in") }
    it { should have_link("(forget password)", href: new_password_reset_path) }
  end

  describe "login" do
    before { visit login_path }
    
    describe "with invalid infomation" do
      before { click_button "Log in" }
      it { should have_title("Log in") }
      it { should have_selector("div.alert.alert-danger", text: "Invalid") }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector("div.alert.alert-danger") }
      end

    end

    describe "with valid information " do
      let(:activated_user) { FactoryGirl.create(:activated_user) }
      # before do
      #   fill_in "Email",    with: activated_user.email.upcase
      #   fill_in "Password", with: activated_user.password
      #   click_button "Log in"
      # end
      before { sign_in activated_user }

      it { should have_title(activated_user.name) }
      it { should have_link("Users", href: users_path) }
      it { should have_link("Profile", href: user_path(activated_user)) }
      it { should have_link("Settings", href: edit_user_path(activated_user)) }
      it { should have_link("Log out", href: logout_path) }
      it { should_not have_link("Log in", href: login_path) }

      describe "followed by logout" do
        before { click_link "Log out" }
        it { should have_link("Log in") }
      end
      
    end
  end

  describe "authorization" do
    describe "for non-signed-in users" do   # check "before_action" filter
      let(:activated_user) { FactoryGirl.create(:activated_user) }

      it { should_not have_link("Users", href: users_path) }
      it { should_not have_link("Profile", href: user_path(activated_user)) }
      it { should_not have_link("Settings", href: edit_user_path(activated_user)) }
      it { should_not have_link("Log out", href: logout_path) }

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(activated_user)  # loginしていないのでLogin pageに飛ぶ
          sign_in activated_user
        end

        describe "after loging in" do
          it "should render the desired protected page" do
            # frinendly forwording(login前にいたedit_user_path(user)に遷移)
            expect(page).to have_title("Edit user")   
          end

          describe "when loging in again" do
            before do
              delete logout_path
              sign_in activated_user
            end

            it "should render the default(profile) page " do
              expect(page).to have_title(activated_user.name)
            end
          end
        end
      end

      describe "in the Users controller" do
        describe "visiting the edit page" do
          before { visit edit_user_path(activated_user) }
          it { should have_title("Log in") }
        end

        describe "submitting to the updating action" do
          before { patch user_path(activated_user) }    # PATCHのHTTPリクエストを「直接」発行(ブラウザはupdateアクションを直接表示することができない)
          specify { expect(response).to redirect_to(login_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title("Log in") }
        end
      end
      
    end

    pending "as wrong user" do
      let(:activated_user) { FactoryGirl.create(:activated_user) }
      let(:wrong_user) { FactoryGirl.create(:wrong_user) }
      # before { sign_in user, no_capybara: true }
      before do
        visit login_path
        fill_in "Email",    with: activated_user.email
        fill_in "Password", with: activated_user.password
        click_button "Log in"
      end

      # users_controllerのcorrect_user methodの検証
      describe "submitting a GET request to the Users#edit action" do   
        before { get edit_user_path(wrong_user) }   # users#edit
        specify { expect(response.body).not_to match(full_title("Edit user")) }
        specify { expect(response).to redirect_to(root_url) }
      end

      # users_controllerのcorrect_user methodの検証
      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }    # users#update
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    pending "as non-admin user" do
      let(:activated_user) { FactoryGirl.create(:activated_user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(activated_user) }
        specify { expect(response).to redirect_to(root_path) }
      end

    end

  end
end
