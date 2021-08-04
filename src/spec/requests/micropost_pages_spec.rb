require 'rails_helper'

describe "Microposts" do
  subject { page }

  let(:activated_user) { FactoryGirl.create(:activated_user) }
  before { sign_in activated_user }

  describe "micropost creation" do
    before { visit root_path }

    it { should have_link("view my profile", href: user_path(activated_user)) }
    it { should have_content("Micropost Feed") }
    
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

  describe "micropost deleting" do
    before { visit root_path }
    
    describe "with correct-user" do
      let(:activated_user) { FactoryGirl.create(:activated_user) }
      let(:micropost) { activated_user.microposts.build( content: "Lorem ipsum") }

      before do
        micropost.save
        visit root_path
      end

      it { expect{ click_link "delete", match: :first }.to change(Micropost, :count).by(-1) }

      describe "should delete micropost" do
        before { click_link "delete", match: :first }
        it { should have_content("Micropost deleted") }
      end
    end
    
    describe "with non-corrrect-user" do
      let(:user) { FactoryGirl.create(:activated_user) }
      let!(:micropost) { user.microposts.build( content: "Lorem ipsum") }

      before do
        micropost.save
      end
      
      it "should not deleting micropost" do
        expect { delete micropost_path(micropost.id) }.not_to change(Micropost, :count)
      end

    end

  end
end
