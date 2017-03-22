require 'rails_helper'
require 'features/pagination_spec_helper'

RSpec.feature "Content Item Details", type: :feature do
  scenario "the user clicks on the view content item link and is redirected to the content item show page" do
    create :content_item, content_id: "content-id-1", title: "content item title"

    visit "/content_items"
    click_on "content item title"

    expected_path = "/content_items/content-id-1"
    expect(current_path).to eq(expected_path)
  end

  describe 'The user can navigate paged lists of content items' do
    before do
      create_list :content_item, 3
    end

    it_behaves_like "a paginated list", "/content_items"
  end
end
