require 'rails_helper'

describe RelationshipsController do
  let(:activated_user) { FactoryGirl.create(:activated_user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in activated_user, no_capybara: true }

  describe "creating a relationship with AJAX" do

    it "should increment the Relationship count" do
      # xhrメソッド (“XmlHttpRequest” の略) 
      expect do
        post :create, xhr:true, params: { followed_id: other_user.id } 
      end.to change(Relationship, :count).by(1)
    end

    it "should respond with success" do
      post :create, xhr:true, params: { followed_id: other_user.id } 
      expect(response).to be_success
    end
  end

  describe "deatroying a relatinoship with AJAX" do
    before { activated_user.follow(other_user) }
    let(:relationship) do
      activated_user.active_relationships.find_by(followed_id: other_user.id)
    end

    it "should decrement the Relationship count" do
      expect do
        delete :destroy, xhr:true, params: { id: relationship.id } 
      end.to change(Relationship, :count).by(-1)
    end

    it "should respond with success" do
      delete :destroy, xhr:true, params: { id: relationship.id } 
      expect(response).to be_success 
    end
  end

end