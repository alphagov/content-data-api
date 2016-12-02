require 'rails_helper'

RSpec.describe 'content_items/index.html.erb', type: :view do
  let(:content_items) { build_list(:content_item, 2) }

  before { assign(:content_items, content_items) }

  it 'renders the table header with the right headings' do
    render

    expect(rendered).to have_selector('table thead tr:first-child', text: 'Content Ids')
    expect(rendered).to have_selector('table thead tr:nth(1)', text: 'Content URL')
    expect(rendered).to have_selector('table thead', text: 'Title')
  end

  it 'renders a row per Content Item' do
    render

    expect(rendered).to have_selector('table tbody tr', count: 2)
  end

  describe 'row content' do
    it 'contains the content-id in the first column' do
      content_items[0].content_id = 'a-content-id'
      render

      expect(rendered).to have_selector('table tbody tr:first-child td', text: 'a-content-id')
    end

    it 'contains the content\'s url in the second column' do
      content_items[0].link = '/content/1/path'
      render

      expect(rendered).to have_selector('table tbody tr:first-child td:nth(2) a', text: 'https://gov.uk/content/1/path')
    end

    it 'includes the content item title' do
      content_items[0].title = 'a-title'
      render

      expect(rendered).to have_selector('table tbody tr td', text: 'a-title')
    end
  end
end
