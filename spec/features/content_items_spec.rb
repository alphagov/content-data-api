require 'rails_helper'
require 'features/pagination_spec_helper'

RSpec.feature "Content Items List", type: :feature do
  background do
    @content_items = create_list :content_item, 3
  end

  context "list the content items" do
    scenario "the user sees a list of all unfiltered content items" do
      visit 'content_items'

      expect(page).to have_css('table tbody tr', count: 3)
    end

    describe "user can navigate paged lists of content items" do
      it_behaves_like 'a paginated list', 'content_items'
    end
  end

  context "navigation to organisation pages" do
    scenario "clicks through to an organisation" do
      first_content_item = @content_items.first
      first_content_item.organisations << create(:organisation, title: 'the-organisation-title', slug: 'organisation-slug')

      visit 'content_items'
      click_on 'the-organisation-title'

      expected_path = "/organisations/organisation-slug/content_items"
      expect(current_path).to eq(expected_path)
    end
  end
end
