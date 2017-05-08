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

  scenario "Renders the organisations belonging to a Content Item" do
    content_item = create(:content_item).decorate
    content_item.organisations << create(:organisation, title: 'An Organisation')
    content_item.organisations << create(:organisation, title: 'Another Organisation')

    visit "/content_items/#{content_item.id}"

    expect(page).to have_text('An Organisation, Another Organisation')
  end
end
