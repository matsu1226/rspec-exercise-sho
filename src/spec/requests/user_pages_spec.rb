require 'rails_helper'

describe "User pages" do
  subject{ page }   # shouldの呼び出し => Capybaraのpage変数を使用


  describe "after activating user" do
    let(:activated_user) { FactoryGirl.create(:activated_user) }
    before(:each) do
      sign_in activated_user
      visit users_path
    end

    describe "index page" do
      it { should have_title("All users") }
      it { should have_content("All users") }
  
      describe "pagination" do
        before(:all) { 30.times { FactoryGirl.create(:activated_user) } }
        after(:all)  { User.delete_all }
  
        it { should have_selector("div.pagination") }
        it "should list each user" do
          User.paginate(page: 1).each do |user|
            expect(page).to have_selector("li", text: user.name)
          end
        end
      end
  
      describe "delete links" do
        
        it { should_not have_link("delete") }
  
        describe "as an admin user" do
          let(:admin) { FactoryGirl.create(:admin) }
          before do
            sign_in admin
            visit users_path
          end
  
          it { should have_link("delete", href: user_path(User.first)) }
          it "should be able to delete another user" do
            expect do
              click_link("delete", match: :first)
            end.to change(User, :count).by(-1)
          end
          it { should_not have_link("delete", href: user_path(admin)) }
        end
      end
  
    end

    describe "edit page"do
      # let(:activated_user) { FactoryGirl.create(:activated_user) }
      # # before { visit edit_user_path(user) }
      before do
        sign_in activated_user
        visit edit_user_path(activated_user)
      end

      describe "page"do
        it { should have_content("Update your profile") }
        it { should have_title("Edit user") }
        it { should have_link("change", href: "http://gravatar.com/emails") }
      end

      describe "with invalid information" do
        before { click_button "Save changes" }

        it { should have_content("error")}
      end

      describe "with valid information"do
        let(:new_name) { "New Name" }
        let(:new_email) { "new@example.com" }

        before do
          fill_in "Name",    with: new_name
          fill_in "Email",    with: new_email
          fill_in "Password", with: activated_user.password
          fill_in "Confirmation", with: activated_user.password
          click_button "Save changes"
        end

        it { should have_title(new_name) }
        it { should have_selector("div.alert.alert-success") }
        it { should have_link("Log out", href: logout_path) }
        specify { expect(activated_user.reload.name).to eq new_name }
        specify { expect(activated_user.reload.email).to eq new_email }
      end

      describe "forbidden attributes" do
        let(:params) do
          { params: { user: { admin: true, password: activated_user.password, 
                              password_confirmation: activated_user.password }} }
        end
        before do
          sign_in activated_user, no_capybara: true
          patch user_path(activated_user), params   # update actionへの直接アクセス(admin属性付与)
          # def patch(uri, opts = {})   request(PATCH, uri, opts)   end
          
        end
        
        specify { expect(activated_user.reload).not_to be_admin }
      end
    end

    describe "profile page" do
      let!(:m1) { FactoryGirl.create(:micropost, user: activated_user, content: "Foo") }
      let!(:m2) { FactoryGirl.create(:micropost, user: activated_user, content: "Bar") }

      before { visit user_path(activated_user) }

      it { should have_content(activated_user.name) }
      it { should have_title(activated_user.name) }

      describe "microposts" do
        it { should have_content(m1.content) }
        it { should have_content(m2.content) }
        it { should have_content(activated_user.microposts.count) }
      end

      describe "follow/unfolllw buttons" do
        let(:other_user) { FactoryGirl.create(:user) }
        # before { sign_in activated_user }

        describe "following a user" do
          before { visit user_path(other_user) }

          it "should increment the followed user count" do
            expect do
              click_button "Follow"
            end.to change(activated_user.following, :count).by(1)
          end

          it "should increment the other user's followers count" do
            expect do
              click_button "Follow"
            end.to change(other_user.followers, :count).by(1)
          end

          describe "toggling the button" do
            before { click_button "Follow" }
            it { should have_xpath("//input[@value='Unfollow']") }       #
          end
        end

        describe "unfollow a user" do
          before do
            activated_user.follow(other_user)
            visit user_path(other_user)
          end

          it "should decrement the followed user count" do      ##
            expect do
              click_button "Unfollow"
            end.to change(activated_user.following, :count).by(-1)
          end

          it "should decrement the other user's followers count" do       ##
            expect do
              click_button "Unfollow"
            end.to change(other_user.followers, :count).by(-1)
          end

          describe "toggling the button" do
            before { click_button "Unfollow" }
            it { should have_xpath("//input[@value='Follow']") }        ##
          end

        end
      end
    end

    describe "following/followers" do
      let(:activated_user) { FactoryGirl.create(:activated_user) }
      let(:other_user) { FactoryGirl.create(:user) }
      before { activated_user.follow(other_user) }

      describe "followed users" do
        before { visit following_user_path(activated_user) }

        it { should have_title(full_title("Following")) }
        it { should have_selector("h3", text: "Following") }
        it { should have_link(other_user.name, href: user_path(other_user)) }
      end

      describe "followers users" do
        before { visit followers_user_path(other_user) }

        it { should have_title(full_title("Followers")) }
        it { should have_selector("h3", text: "Followers") }
        it { should have_link(activated_user.name, href: user_path(activated_user)) }
      end
    end

  end



  describe "before activating user"do
  
    describe "signup page" do
      before { visit signup_path }
      it { should have_content("Sign up") }
      it { should have_title(full_title("Sign up")) }
    end


    describe "signup" do
      before { visit signup_path }    # users#new
      let(:submit) { "Create my account" }
  
      describe "with invalid infomation" do
        it "should not create a user" do
          expect { click_button submit }.not_to change(User, :count) 
          # { click_button "..."}の前後でUser.countを確認
        end
  
        describe "after submission" do
          before { click_button submit }
  
          it { should have_title("Sign up")}  # create account してないので signup_pathにリダイレクト
          it { should have_content("error")}
        end
      end
  
      describe "with valid information" do
        before do
          fill_in "Name",         with: "Example User"
          fill_in "Email",        with: "user@example.com"
          fill_in "Password",     with: "foobar"
          fill_in "Confirmation", with: "foobar"
        end
        
        after(:all) {
          # 意図的にテスト後にクリアにする
          ActionMailer::Base.deliveries.clear
        }
  
        it "hoge should create a user" do
          expect { click_button submit }.to change(User, :count).by(1)
        end

        describe "after saving the user" do
          before { click_button submit }    # @user.save && mailが送られたたはず。
          let(:user) { User.find_by(email: "user@example.com") }
          # find_byで"DBから"探すので、activation_token属性は得られない。
  
          it { should have_content("Sign up now!")}   # root_urlにリダイレクト
          it { expect(ActionMailer::Base.deliveries.size).to eq 1 }

          describe "before user non-activated" do
            # sessions#create 
            # before { sign_in user }
            before do
              visit login_path
              fill_in "Email",    with: user.email
              fill_in "Password", with: user.password
              click_button "Log in"
            end
            it { should have_content("Invalid email/password combination")}
          end
  
          pending "after user activate" do  # capybara-emailを使うといいらしい。。。
            # mailのactivationリンクをクリックすると、
            before { get edit_account_activation_path(user.activation_token, email: user.email) }
            it { should have_title(user.name)}  # user_path(user) にリダイレクトしているはず。
          end
        end
  
      end
  
    end

  end

end
