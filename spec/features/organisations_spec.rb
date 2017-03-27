require 'rails_helper'
require 'features/pagination_spec_helper'

RSpec.feature "Organisations list", type: :feature do
  scenario "The user can see all the organisations" do
    create :organisation, title: "organisation title"

    visit organisations_path

    expect(page).to have_selector('tbody > tr', count: 1)
    expect(page).to have_selector('tbody tr:first-child td', text: "organisation title")
  end

  scenario "The user can navigate to an organisation detail page" do
    create :organisation, title: "organisation title", content_id: "the-content-id"

    visit organisations_path
    click_on "organisation title"

    expected_path = "/content_items?organisation_id=the-content-id"
    expect(current_url).to include(expected_path)
  end

  describe 'The user can navigate paged lists of organisations' do
    before do
      create_list :organisation, 3
    end

    it_behaves_like "a paginated list", "organisations/"
  end
end
