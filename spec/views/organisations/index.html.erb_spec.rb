require 'rails_helper'

RSpec.describe 'organisations/index.html.erb', type: :view do
  let(:organisations) { build_list :organisation, 2 }

  before do
    allow(view).to receive(:paginate)
    assign(:organisations, organisations)
  end

  describe "page" do
    it "should render the title" do
      render

      expect(rendered).to have_selector('h1', text: 'Organisations')
    end

    it "should render table headings" do
      render

      expect(rendered).to have_selector('th', text: "Name")
      expect(rendered).to have_selector('th', text: "Number of content items")
    end
  end

  describe "table content" do
    it "should render a row for each organisation" do
      render

      expect(rendered).to have_selector('tbody tr', count: 2)
    end

    it "should render a link for each organisation" do
      organisations.first.title = "Organisation 1"
      organisations.first.slug = "the-slug"
      organisation_link = content_items_path(organisation_slug: "the-slug")
      render

      expect(rendered).to have_selector("a[href='#{organisation_link}']", text: "Organisation 1")
    end

    it "should render total number of content items per organisation" do
      allow(organisations.first).to receive(:content_items).and_return(['An item'])
      render

      expect(rendered).to have_selector("tr:nth(1) td", text: "1")
    end
  end

  describe 'Kaminari' do
    it 'should paginate the organisations' do
      expect(view).to receive(:paginate)
      render
    end
  end
end
