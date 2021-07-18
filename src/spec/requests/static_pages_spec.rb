require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "Home page" do
    # Sample Appの文字列を持つことを確認
    it "should have a content 'Sample App'" do
      # get static_pages_index_path
      visit '/static_pages/home'
      expect(page).to have_content('Sample App')
    end
    # full_title custom helperの条件分岐が機能しているかを確認(provide(:title)がない場合)
    it "should have the base title" do
      visit '/static_pages/home'
      expect(page).to have_title("Ruby on Rails Tutorial Sample App")
    end
    # Home文字列を削除したことを確認
    it"should not have a custom page title"do
      visit '/static_pages/home'
      expect(page).not_to have_title('Home |') 
    end
  end


  describe "Help page" do
    it "should have the content 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end
    it "should have the title 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_title("Help | Ruby on Rails Tutorial Sample App")
    end
  end


  describe "About page" do
    it "should have the content 'About Us'" do
      visit '/static_pages/about'
      expect(page).to have_content('About Us')
    end
    it "should have the title 'About Us'" do
      visit '/static_pages/about'
      expect(page).to have_title("About Us | Ruby on Rails Tutorial Sample App")
    end
  end
end
