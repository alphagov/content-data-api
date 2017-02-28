require 'rails_helper'

RSpec.describe 'content_items/show.html.erb', type: :view do
  let(:content_item) { build(:content_item) }
  let(:organisation) { build(:organisation) }

  before do
    assign(:content_item, content_item)
    assign(:organisation, organisation)
    content_item.organisations << organisation
  end

  it 'renders the table header with the right headings' do
    render

    expect(rendered).to have_selector('table th:first-child', text: 'Content item attribute')
    expect(rendered).to have_selector('table th:nth(2)', text: 'Value')
  end

  it 'renders the title' do
    content_item.title = 'A Title'
    render

    expect(rendered).to have_selector('h1', text: 'A Title')
  end

  it 'renders the url' do
    content_item.base_path = '/content/1/path'
    content_item.title = 'A Title'
    render

    expect(rendered).to have_selector('td', text: 'Page on GOV.UK')
    expect(rendered).to have_selector('td + td a[href="https://gov.uk/content/1/path"]', text: 'A Title')
  end

  it 'renders the document type' do
    content_item.document_type = 'guidance'
    render

    expect(rendered).to have_selector('td', text: 'Type of document')
    expect(rendered).to have_selector('td + td', 'text': 'guidance')
  end

  it 'renders the number of views' do
    content_item.unique_page_views = 10
    render

    expect(rendered).to have_selector('td', text: 'Unique page views (last 1 month)')
    expect(rendered).to have_selector('td + td', 'text': 10)
  end

  it 'renders the last updated date' do
    Timecop.freeze('2016-3-20') do
      content_item.public_updated_at = Date.parse('2016-1-20')
      render
    end

    expect(rendered).to have_selector('td', text: 'Last updated')
    expect(rendered).to have_selector('td + td', text: '2 months ago')
  end

  it 'renders the description of the content item' do
    content_item.description = 'The description of a content item'
    render

    expect(rendered).to have_selector('td', text: 'Description')
    expect(rendered).to have_selector('td + td', text: 'The description of a content item')
  end

  context "content items belong to multiple organisations" do
    let(:content_item) { create(:content_item_with_organisations, organisations_count: 2) }

    it 'renders the organisations names' do
      content_item.organisations[0].title = 'An Organisation'
      content_item.organisations[1].title = 'Another Organisation'
      render

      expect(rendered).to have_selector('td', text: 'Organisation')
      expect(rendered).to have_selector('td + td', text: 'An Organisation, Another Organisation')
    end

    context 'item has never been published' do
      it 'renders for no last updated value' do
        content_item.public_updated_at = nil
        render

        expect(rendered).to have_selector('table tbody tr:nth(5) td:nth(2)', text: 'Never')
      end
    end
  end
end
