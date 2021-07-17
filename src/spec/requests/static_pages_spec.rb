require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "Home page" do
    it "should have a content 'Sample App'" do
      # get static_pages_index_path
      visit '/static_pages/home'
      expect(page).to have_content('Sample App')
    end
    it "should have the title 'Home'" do
      visit '/static_pages/home'
      expect(page).to have_title("Home | Ruby on Rails Tutorial Sample App")
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
