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

  describe "Filtering content items" do
    context "by organisation" do
      scenario "the user selects an organisation from the organisations select box, clicks the filter button and retrieves a filtered list of the organisation's content items" do
        create :organisation, slug: "the-slug-1", title: "title 1"
        create :organisation, slug: "the-slug-2", title: "title 2"

        visit "/content_items/filter"
        select "title 2", from: "organisation_slug"
        click_on "Filter"

        expected_path = URI.escape "/content_items?utf8=✓&organisation_slug=the-slug-2"

        expect(current_url).to include(expected_path)
      end
    end

    context "by taxon" do
      scenario "the user selects a taxon from the taxons box, clicks the filter button and retrieves the filtered list of taxon's content items" do
        create :taxonomy, title: "Taxon A"

        visit "/content_items/filter"
        select "Taxon A", from: "taxonomy_title"
        click_on "Filter"

        expected_path = URI.escape "/content_items?utf8=✓&organisation_slug=&taxonomy_title=Taxon+A"

        expect(current_url).to include(expected_path)
      end
    end
  end
end
