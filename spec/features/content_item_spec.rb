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

  scenario "Renders core attributes from the Content Item" do
    content_item = create(:content_item,
      title: "a-title",
      base_path: "/content/1/path",
      document_type: "guidance",
      description: "a-description",
      public_updated_at: 2.months.ago,
    )

    visit "/content_items/#{content_item.id}"
    expect(page).to have_text("a-title")
    expect(page).to have_link("a-title", href: "https://gov.uk/content/1/path")
    expect(page).to have_text("guidance")
    expect(page).to have_text("a-description")
    expect(page).to have_text("2 months ago")
  end

  scenario "Renders the number of PDFs" do
    content_item = create :content_item, number_of_pdfs: 99

    visit "/content_items/#{content_item.id}"

    expect(page).to have_text("99")
  end

  scenario "Renders the organisations belonging to a Content Item" do
    content_item = create(:content_item).decorate
    content_item.organisations << create(:organisation, title: 'An Organisation')
    content_item.organisations << create(:organisation, title: 'Another Organisation')

    visit "/content_items/#{content_item.id}"

    expect(page).to have_text('An Organisation, Another Organisation')
  end
end
