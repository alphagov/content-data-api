require 'rails_helper'

RSpec.describe 'content_items/index.html.erb', type: :view do
  describe 'Search form' do
    before do
      allow(view).to receive(:paginate)
      assign(:content_items, ContentItemsDecorator.new([]))
    end

    it 'has an input to enter the query' do
      render

      expect(rendered).to have_selector('form input[name=query]')
    end

    it 'has a button to perform the query' do
      render

      expect(rendered).to have_selector('form input[type=submit]')
    end
  end

  context 'unfiltered' do
    let(:content_items) { ContentItemsDecorator.new(build_list(:content_item, 2)) }

    before do
      allow(view).to receive(:paginate)
      assign(:content_items, content_items)
    end

    it 'renders a page title' do
      render

      expect(rendered).to have_selector('h1', text: 'GOV.UK')
    end

    it 'renders the table header with the right headings' do
      render

      expect(rendered).to have_selector('table thead', text: 'Title')
      expect(rendered).to have_selector('table thead tr:first-child th:nth(2)', text: 'Organisation')
      expect(rendered).to have_selector('table thead tr:first-child th:nth(3)', text: 'Type of Document')
      expect(rendered).to have_selector('table thead tr:first-child th:nth(4)', text: 'Unique page views (last 1 month)')
      expect(rendered).to have_selector('table thead tr:first-child th:nth(5)', text: 'Last Updated')
    end

    it 'renders a row per Content Item' do
      render

      expect(rendered).to have_selector('table tbody tr', count: 2)
    end

    context 'items that have never been published' do
      it 'renders for no last updated value' do
        content_items[0].public_updated_at = nil
        render

        expect(rendered).to have_selector('table tr td:nth(5)', text: 'Never')
      end
    end

    describe 'row content' do
      it 'items depict the Organisations they each belong to' do
        content_items[0].organisations.build(title: 'An organisation', slug: 'organisation-slug ')
        render

        expect(rendered).to have_text('An organisation')
      end
    end
  end

  context "filter by org" do
    let(:organisation) { build(:organisation) }
    let(:content_items) { ContentItemsDecorator.new(build_list(:content_item, 2)) }

    before do
      allow(view).to receive(:paginate)
      allow(view).to receive(:page_entries_info)
      assign(:content_items, content_items)
      assign(:organisation, organisation)
    end

    it 'renders the title of the organisation' do
      allow(content_items).to receive(:header).and_return('A Title')
      render

      expect(rendered).to have_selector('h1', text: 'A Title')
    end

    it 'renders the table header with the right headings' do
      render

      expect(rendered).to have_selector('table thead', text: 'Title')
      expect(rendered).to have_selector('table thead tr:first-child th:nth(2)', text: 'Type of Document')
      expect(rendered).to have_selector('table thead tr:first-child th:nth(3)', text: 'Unique page views (last 1 month)')
      expect(rendered).to have_selector('table thead tr:first-child th:nth(4)', text: 'Last Updated')
    end

    it 'renders a row per Content Item' do
      render

      expect(rendered).to have_link(content_items.first.title, href: content_item_path(id: content_items.first.id))
    end

    it 'returns the max page size number of content items per page' do
      render
      expect(rendered).to have_selector('table tbody tr', count: 2)
    end

    describe 'Kaminari' do
      it 'uses Kaminari to paginate the pages' do
        expect(view).to receive(:paginate)
        render
      end

      it 'returns the max page size number of content items per page' do
        render
        expect(rendered).to have_selector("table tbody tr", count: 2)
      end
    end

    describe 'row content' do
      it 'includes the content item title' do
        content_items[0].title = 'a-title'
        render

        expect(rendered).to have_link('a-title', href: content_item_path(id: content_items.first.id))
      end

      it 'includes the last time the content was updated' do
        Timecop.freeze(Time.parse('2016-3-20')) do
          content_items[0].public_updated_at = Time.parse('2016-1-20')
          render

          expect(rendered).to have_selector('table tbody tr td', text: '2 months ago')
        end
      end

      it 'contains a descending and ascending links in table heading' do
        render
        href = content_items_path(organisation_slug: organisation.slug, order: :asc, sort: :public_updated_at)

        expect(rendered).to have_link('Last Updated', href: href)
      end

      context 'items that have never been published' do
        it 'renders for no last updated value' do
          content_items[0].public_updated_at = nil
          render

          expect(rendered).to have_selector('table tr td:nth(4)', text: 'Never')
        end
      end
    end
  end
end
