require 'rails_helper'

RSpec.feature "Content Item Details", type: :feature do
  let(:organisation) { create(:organisation_with_content_items, content_items_count: 1) }

  scenario "the user clicks on the view content item link and is redirected to the content item show page" do
    visit "organisations/#{organisation.id}/content_items"
    click_on "View detail"

    expected_path = "/organisations/#{organisation.id}/content_items/#{organisation.content_items[0].id}"

    expect(current_path).to eq(expected_path)
  end
end
