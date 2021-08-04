require 'rails_helper'

describe Micropost do
  let(:user) { FactoryGirl.create(:user) }
  before do
    @micropost = user.microposts.build( content: "Lorem ipsum" )
  end

  subject { @micropost }

  it { should respond_to(:content) }  # respond_to(:method) => メソッドがあることをテスト
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  # its(:user) { should eq user }
  it { expect(@micropost.user).to eq user }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end

  describe "when content is empty" do
    before { @micropost.content = "" }
    it { should_not be_valid }
  end

  describe "when content is over 140 characters" do
    before { @micropost.content = "a" * 141 }
    it { should_not be_valid }
  end
end
