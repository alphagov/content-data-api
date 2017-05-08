require 'rails_helper'

RSpec.describe 'content_items/index.html.erb', type: :view do
  before do
    assign(:organisations, [])
    assign(:taxonomies, [])
    assign(:metrics, total_pages: {}, zero_page_views: {}, pages_not_updated: {}, pages_with_pdfs: {})
    assign(:content_items, ContentItemsDecorator.new(build_list(:content_item, 1)))
    allow(view).to receive(:paginate)
  end

  context 'main content' do
    let(:content_items) { ContentItemsDecorator.new(build_list(:content_item, 2)) }

    before do
      assign(:content_items, content_items)
    end

    it 'renders a row per Content Item' do
      render

      expect(rendered).to have_selector('table tbody tr', count: 2)
    end

  end

  describe 'Kaminari' do
    let(:content_items) { ContentItemsDecorator.new(build_list(:content_item, 2)) }

    before do
      allow(view).to receive(:paginate)
      assign(:content_items, content_items)
    end

    it 'uses Kaminari to paginate the pages' do
      expect(view).to receive(:paginate)
      render
    end

    it 'returns the max page size number of content items per page' do
      render
      expect(rendered).to have_selector("table tbody tr", count: 2)
    end
  end
end
