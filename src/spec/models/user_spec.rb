require 'rails_helper'

describe User do
  before do
    @user =User.new(name: "Example User", email: "user@example.com",
                    password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }   # shouldの対象

  it { should respond_to(:name) }   # @userがname method(もしくはattributes)を持つことを確認
  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:remember_digest) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:active_relationships) }
  it { should respond_to(:following) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow) }
  it { should respond_to(:unfollow) }

  it { should be_valid }  # User model の validate test( = "@user.valid?")
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }    # "@user.admin? == true"  (@userに対してadmin? methodが使えることを確認)
  end

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }   # name = "" ならvalidation 通らないはず。
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }   
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }   
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      address = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
      address.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      address = %w[user@foo.COM THE_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      address.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExaMple.CoM" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save    
      # => @userのcache上の更新をDBに保存(\models\user.rbのbefore_saveの処理が実行されるはず)
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe "when email address is already token" do
    before do
      user_with_same_email = @user.dup    # dup => オブジェクトのコピーを作成して返すメソッド
      user_with_same_email.email = @user.email.upcase   #メールアドレスでは大文字小文字が区別されない
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present"do
    before do
      @user =User.new(name: "Example User", email: "user@example.com",
                      password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }  # let を用いた、ローカル変数の作成
    
    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }  #authenticate methodの機能確認。
    end

    describe "with invallid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be false }
      # specify(「明記する」)はitと同義(今回の文章だと、英語の文法の点で、itよりもspecifyのほうが自然)
    end

  end

  describe "micropost associations" do
    before { @user.save }
    let!(:older_micropost) do   # "!"をつけることで即参照される（遅延参照されない）
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right microposts in the right order" do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "should destroy associated microposts" do
      microposts = @user.microposts.to_a  # to_aメソッド=>マイクロポストのコピーが配列化されて作成
      @user.destroy                       # DB上で@userとそれに紐づくmicropostが削除(変数micropostsは存在したまま)
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      it { expect(@user.feed).to include(older_micropost) }
      it { expect(@user.feed).to include(newer_micropost) }
      it { expect(@user.feed).not_to include(unfollowed_post) }
    end
  end

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow(other_user)
    end

    it { should be_following(other_user) }    # "@user.following?(other_user)==true"?
    it { expect(@user.following).to include(other_user) }

    describe "followed users" do
      it { expect(other_user.followers).to include(@user) }
    end

    describe "and unfollowing" do
      before { @user.unfollow(other_user) }

      it { should_not be_following(other_user) }
      # it { expect(@user.following).not_to include(other_user) }
    end
  end
end
