require 'rails_helper'

describe "Microposts" do
  subject { page }

  let(:activated_user) { FactoryGirl.create(:activated_user) }
  before { sign_in activated_user }

  describe "micropost creation" do
    before { visit root_path }
    
    describe "with invalid information" do
      
      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end
  
      describe "error messages" do
        before { click_button "Post" }
        it { should have_content("error") }
      end
    end
  
    describe "with valid information" do
      before { fill_in "micropost_content", with: "Lorem ipsum" }
      
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
      
    end
  end
end
