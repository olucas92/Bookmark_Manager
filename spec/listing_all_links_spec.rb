require 'spec_helper'

feature "User browses the list of links" do

  before(:each) {
    Link.create(:url => "http://makersacademy.com",
      :title => "Makers Academy")
  }

  scenario "when opening the home page" do
    visit '/'
    expect(page).to have_content("Makers Academy")
  end

  # scenario "filtered by a tag" do
  #   visit '/tags/search'
  #   expect(page).not_to have_content("Makers Academy")
  #   expect(page).not_to have_content("Code.org")
  #   expect(page).to have_content("Google")
  #   expect(page).to have_content("Bing")
  # end

end