require 'rails_helper'

RSpec.describe 'content_items/index.html.erb', type: :view do
  let(:content_items) { FactoryGirl.build_list(:content_item, 2) }

  before { assign(:content_items, content_items) }

  it 'render the table header' do
    render

    expect(rendered).to have_selector('table thead', text: 'Content Ids')
  end

  it 'renders a row per Content Item' do
    render

    expect(rendered).to have_selector('table tbody tr', count: 2)
  end

  describe 'row content' do
    it 'includes the content-id' do
      content_items[0].content_id = 'a-content-id'
      render

      expect(rendered).to have_selector('table tbody tr td', text: 'a-content-id')
    end
  end
end
