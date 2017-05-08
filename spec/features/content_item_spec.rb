require 'rails_helper'
require 'features/pagination_spec_helper'

RSpec.feature "Content Item Details", type: :feature do
  scenario "the user clicks on the view content item link and is redirected to the content item show page" do
    create :content_item, id: 1, title: "content item title"

    visit "/content_items"
    click_on "content item title"

    expected_path = "/content_items/1"
    expect(current_path).to eq(expected_path)
  end
end
