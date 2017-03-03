require 'rails_helper'

RSpec.describe TaxonomyParser do
  describe "#parse" do
    it 'returns an array of taxons ID' do
      content_item = {
        links: {
          taxons: [{ content_id: 1 }, { content_id: 2 }]
        }
      }
      taxons = TaxonomyParser.parse(content_item)
      expect(taxons.length).to eq(2)
    end

    it 'returns an empty array when no taxons are present' do
      content_item = { links: {} }
      taxons = TaxonomyParser.parse(content_item)
      expect(taxons.length).to eq(0)
    end

    it 'returns an empty array when no links are present' do
      content_item = {}
      taxons = TaxonomyParser.parse(content_item)
      expect(taxons.length).to eq(0)
    end
  end
end
