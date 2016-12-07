require 'rails_helper'

RSpec.describe 'content_items/index.html.erb', type: :view do
  let(:content_items) { build_list(:content_item, 2) }

  before { assign(:content_items, content_items) }

  it 'renders the table header with the right headings' do
    render

    expect(rendered).to have_selector('table thead', text: 'Content URL')
    expect(rendered).to have_selector('table thead', text: 'Title')
    expect(rendered).to have_selector('table thead', text: 'Last Updated')
  end

  it 'renders a row per Content Item' do
    render

    expect(rendered).to have_selector('table tbody tr', count: 2)
  end

  describe 'row content' do
    it 'contains the content\'s url' do
      content_items[0].link = '/content/1/path'
      render

      expect(rendered).to have_selector('table tbody td a', text: 'https://gov.uk/content/1/path')
    end

    it 'includes the content item title' do
      content_items[0].title = 'a-title'
      render

      expect(rendered).to have_selector('table tbody tr td', text: 'a-title')
    end

    it 'includes the last time the content was updated' do
      Timecop.freeze(Time.parse('2016-3-20')) do
        content_items[0].public_updated_at = Time.parse('2016-1-20')
        render

        expect(rendered).to have_selector('table tbody tr td', text: '2 months ago')
      end
    end
  end
end
