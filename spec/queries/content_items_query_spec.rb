require 'rails_helper'

RSpec.describe ContentItemsQuery, type: :query do
  subject { described_class }

  context "searching by title" do
    it "returns content_items case insensitively" do
      create(:content_item, title: 'title 1')
      create(:content_item, title: 'title 2')

      results = subject.build(query: 'TITLE 1')

      expect(results.count).to eq(1)
      expect(results.first.title).to eq('title 1')
    end
  end

  context "sorting with parameters" do
    before do
      create(:content_item, id: 1, public_updated_at: Time.parse("2016-12-09"))
      create(:content_item, id: 2, public_updated_at: Time.parse("2015-12-09"))
    end

    it "returns content_items sorted on a column ascending" do
      results = subject.build(sort: :public_updated_at, order: :asc)

      expect(results.pluck(:id)).to eq([2, 1])
    end

    it "returns content_items sorted on a column descending" do
      results = subject.build(sort: :public_updated_at, order: :desc)

      expect(results.pluck(:id)).to eq([1, 2])
    end
  end

  context "filtering by relationships" do
    it "returns the content items belonging to the organisation" do
      create(:content_item)
      content_items = [create(:content_item)]
      organisation = create(:organisation, content_items: content_items)

      results = subject.build(organisation: organisation)

      expect(results).to match_array(content_items)
    end

    it "returns the content items belonging to the taxonomy" do
      create(:content_item)
      content_items = [create(:content_item)]
      taxonomy = create(:taxonomy, content_items: content_items)

      results = subject.build(taxonomy: taxonomy)

      expect(results).to match_array(content_items)
    end

    it "returns the content items belonging to the organisation and taxonomy" do
      create(:content_item)
      content_items = [create(:content_item)]
      taxonomy = create(:taxonomy, content_items: content_items)
      organisation = create(:organisation, content_items: content_items)

      results = subject.build(organisation: organisation, taxonomy: taxonomy)

      expect(results).to match_array(content_items)
    end

    it "returns the content items belonging to the organisation and taxonomy where the title is like the query" do
      content_items = [create(:content_item, title: "title 1")]
      taxonomy = create(:taxonomy, content_items: content_items)
      organisation = create(:organisation, content_items: content_items)

      results = subject.build(organisation: organisation, taxonomy: taxonomy, query: "title 1")

      expect(results).to match_array(content_items)
    end
  end
end
