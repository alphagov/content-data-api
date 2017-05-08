require 'rails_helper'

RSpec.describe 'content_items/show.html.erb', type: :view do
  let(:content_item) { build(:content_item).decorate }
  let(:organisation) { build(:organisation) }
  let(:taxonomy) { build(:taxonomy, title: "taxon title") }

  before do
    assign(:content_item, content_item)
    assign(:organisation, organisation)
    content_item.organisations << organisation
  end

  it 'renders the number of views' do
    content_item.unique_page_views = 10
    render

    expect(rendered).to have_selector('td', text: 'Page views (1 month)')
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

  it 'renders a link to FeedEx' do
    content_item.base_path = '/the-base-path'
    feedex_link = "#{Plek.find('support')}/anonymous_feedback?path=/the-base-path"
    render

    expect(rendered).to have_link('View feedback on FeedEx', href: feedex_link)
  end

  it 'renders the taxonomies' do
    content_item.taxonomies = [taxonomy]
    render

    expect(rendered).to have_selector('td', text: 'Taxonomies')
    expect(rendered).to have_selector('td + td', text: "taxon title")
  end

  context 'item has never been published' do
    it 'renders for no last updated value' do
      content_item.public_updated_at = nil
      render

      expect(rendered).to have_selector('table tbody tr:nth(5) td:nth(2)', text: 'Never')
    end
  end
end
