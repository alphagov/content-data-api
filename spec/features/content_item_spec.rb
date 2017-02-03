require 'rails_helper'
require 'features/pagination_spec_helper'

RSpec.feature "Content Item Details", type: :feature do
  scenario "the user clicks on the view content item link and is redirected to the content item show page" do
    organisation = create :organisation, slug: "the-slug"
    create :content_item, id: 1, title: "content item title", organisations: [organisation]

    visit "organisations/the-slug/content_items"
    click_on "content item title"

    expected_path = "/organisations/the-slug/content_items/1"
    expect(current_path).to eq(expected_path)
  end

  describe 'The user can navigate paged lists of content items' do
    before do
      create :organisation_with_content_items, slug: "the-slug", content_items_count: 3
    end

    it_behaves_like "a paginated list", "organisations/the-slug/content_items"
  end
end
