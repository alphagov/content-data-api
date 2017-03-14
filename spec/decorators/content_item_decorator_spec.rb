require "rails_helper"

RSpec.describe ContentItemDecorator, type: :decorator do
  describe '#organisation_links' do
    let(:organisations) do
      [
        build(:organisation, slug: 'slug-1', title: 'title-1'),
        build(:organisation, slug: 'slug-2', title: 'title-2')
      ]
    end

    let(:content_item) { build(:content_item, organisations: organisations).decorate }

    it 'has a comma between names' do
      organisation_links = content_item.organisation_links

      expect(organisation_links).to include(%{<a href=\"/content_items?organisation_slug=slug-1\">title-1</a>})
      expect(organisation_links).to include(%{<a href=\"/content_items?organisation_slug=slug-2\">title-2</a>})
    end
  end

  describe "#list_taxons" do
    let(:taxonomies) { [build(:taxonomy, title: 'taxon 1'), build(:taxonomy, title: 'taxon 2')] }
    let(:content_item) { build(:content_item, taxonomies: taxonomies).decorate }

    it "returns a string of taxons separated by a comma" do
      taxons = content_item.taxons_as_string
      expect(taxons).to eq("taxon 1, taxon 2")
    end
  end
end
