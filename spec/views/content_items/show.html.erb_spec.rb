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

  it 'renders a link to FeedEx' do
    content_item.base_path = '/the-base-path'
    feedex_link = "#{Plek.find('support')}/anonymous_feedback?path=/the-base-path"
    render

    expect(rendered).to have_link('View feedback on FeedEx', href: feedex_link)
  end

  context 'item has never been published' do
    it 'renders for no last updated value' do
      content_item.public_updated_at = nil
      render

      expect(rendered).to have_selector('table tbody tr:nth(5) td:nth(2)', text: 'Never')
    end
  end
end
