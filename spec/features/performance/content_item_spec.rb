require 'features/common/pagination_spec_helper'

RSpec.feature "Content Item Details", type: :feature do
  before do
    create(:user)
  end

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
      public_updated_at: 2.months.ago,)

    visit "/content_items/#{content_item.id}"
    expect(page).to have_text("a-title")
    expect(page).to have_link("a-title", href: "https://gov.uk/content/1/path")
    expect(page).to have_text("Guidance")
    expect(page).to have_text("a-description")
    expect(page).to have_text("2 months ago")
  end

  scenario "Renders the number of PDFs" do
    content_item = create :content_item, number_of_pdfs: 99

    visit "/content_items/#{content_item.id}"

    expect(page).to have_text("99")
  end

  scenario "Renders the taxons" do
    content_item = create(:content_item)
    content_item.taxons << create(:taxon, title: 'A Taxon')
    content_item.taxons << create(:taxon, title: 'Another Taxon')

    visit "/content_items/#{content_item.id}"

    expect(page).to have_text('A Taxon, Another Taxon')
  end

  scenario "Renders stats for Google Analytics" do
    content_item = create :content_item, one_month_page_views: 77

    visit "/content_items/#{content_item.id}"

    expect(page).to have_text("77")
  end

  scenario "Renders feedex details" do
    content_item = create :content_item, base_path: '/the-base-path'

    visit "/content_items/#{content_item.id}"

    feedex_link = "http://support.dev.gov.uk/anonymous_feedback?path=/the-base-path"
    expect(page).to have_link('View feedback on FeedEx', href: feedex_link)
  end

  scenario "Renders the organisations belonging to a Content Item" do
    content_item = create(:content_item)
    content_item.organisations << create(:organisation, title: 'An Organisation')
    content_item.organisations << create(:organisation, title: 'Another Organisation')

    visit "/content_items/#{content_item.id}"

    expect(page).to have_text('An Organisation, Another Organisation')
  end

  scenario "Renders when an item has not been published" do
    content_item = create :content_item, public_updated_at: nil

    visit "/content_items/#{content_item.id}"

    expect(page).to have_text("Never")
  end
end
