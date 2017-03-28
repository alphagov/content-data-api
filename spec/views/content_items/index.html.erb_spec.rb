require 'rails_helper'

RSpec.describe 'content_items/index.html.erb', type: :view do
  context "sidebar content" do
    let(:content_items) { ContentItemsDecorator.new(build_list(:content_item, 1)) }

    before do
      allow(view).to receive(:paginate)
      assign(:organisations, [])
      assign(:taxonomies, [])
      assign(:content_items, content_items)
    end

    it "assigns the sidebar content block" do
      expect(view).to receive(:content_for).with(:sidebar)

      render
    end
  end

  context 'main content' do
    let(:content_items) { ContentItemsDecorator.new(build_list(:content_item, 2)) }

    before do
      allow(view).to receive(:paginate)
      assign(:organisations, [])
      assign(:taxonomies, [])
      assign(:content_items, content_items)
    end

    it 'renders a page title' do
      allow(content_items).to receive(:header).and_return('A Title')
      render

      expect(rendered).to have_selector('h1', text: 'A Title')
    end

    it 'renders the table header with the right headings' do
      render

      expect(rendered).to have_selector('table thead', text: 'Title')
      expect(rendered).to have_selector('table thead tr:first-child th', text: 'Type of Document')
      expect(rendered).to have_selector('table thead tr:first-child th', text: 'Page views (1 month)')
      expect(rendered).to have_selector('table thead tr:first-child th', text: 'Last Updated')
    end

    it 'renders a row per Content Item' do
      render

      expect(rendered).to have_selector('table tbody tr', count: 2)
    end

    describe 'row content' do
      it "renders item title" do
        allow(content_items[0]).to receive(:title).and_return("item title")

        render

        expect(rendered).to have_text('item title')
      end

      it "renders item document type" do
        allow(content_items[0]).to receive(:document_type).and_return("a document type")

        render

        expect(rendered).to have_text('a document type')
      end

      it "renders item page views" do
        allow(content_items[0]).to receive(:unique_page_views).and_return("1234")

        render

        expect(rendered).to have_text('1234')
      end

      it "renders item last updated" do
        Timecop.freeze(Time.parse('2016-3-20')) do
          allow(content_items[0]).to receive(:public_updated_at).and_return(Time.parse('2016-1-20'))

          render

          expect(rendered).to have_text('2 months ago')
        end
      end

      it "renders 'never' if no item last updated" do
        allow(content_items[0]).to receive(:public_updated_at).and_return(nil)

        render

        expect(rendered).to have_text('Never')
      end
    end
  end

  describe 'Kaminari' do
    let(:content_items) { ContentItemsDecorator.new(build_list(:content_item, 2)) }

    before do
      allow(view).to receive(:paginate)
      allow(view).to receive(:page_entries_info)
      assign(:content_items, content_items)
      assign(:organisations, [])
      assign(:taxonomies, [])
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
