require 'rails_helper'

RSpec.describe Queries::ContentItemsQuery, type: :query do
  subject { described_class }

  context "searching by title" do
    it "returns content_items case insensitively" do
      create(:content_item, title: 'title 1')
      create(:content_item, title: 'title 2')

      results = subject.new(query: 'TITLE 1').results

      expect(results.count).to eq(1)
      expect(results.first.title).to eq('title 1')
    end

    it "returns all content items if the query is empty and a title is nil" do
      create(:content_item, title: 'title 1')
      create(:content_item, title: nil)

      results = subject.new(query: '').results

      expect(results.count).to eq(2)
    end
  end

  context "sorting with parameters" do
    before do
      create(:content_item, id: 1, public_updated_at: Time.parse("2016-12-09"))
      create(:content_item, id: 2, public_updated_at: Time.parse("2015-12-09"))
    end

    it "returns content_items sorted on a column ascending" do
      results = subject.new(sort: :public_updated_at, order: :asc).results

      expect(results.pluck(:id)).to eq([2, 1])
    end

    it "returns content_items sorted on a column descending" do
      results = subject.new(sort: :public_updated_at, order: :desc).results

      expect(results.pluck(:id)).to eq([1, 2])
    end
  end

  context "filtering by relationships" do
    it "returns the content items belonging to the organisation" do
      create(:content_item)
      content_items = [create(:content_item)]
      organisation = create(:organisation, content_items: content_items)

      results = subject.new(organisation: organisation).results

      expect(results).to match_array(content_items)
    end

    it "returns the content items belonging to the taxonomy" do
      create(:content_item)
      content_items = [create(:content_item)]
      taxonomy = create(:taxonomy, content_items: content_items)

      results = subject.new(taxonomy: taxonomy).results

      expect(results).to match_array(content_items)
    end

    it "returns the content items belonging to the organisation and taxonomy" do
      create(:content_item)
      content_items = [create(:content_item)]
      taxonomy = create(:taxonomy, content_items: content_items)
      organisation = create(:organisation, content_items: content_items)

      results = subject.new(organisation: organisation, taxonomy: taxonomy).results

      expect(results).to match_array(content_items)
    end

    it "returns the content items belonging to the organisation and taxonomy where the title is like the query" do
      content_items = [create(:content_item, title: "title 1")]
      taxonomy = create(:taxonomy, content_items: content_items)
      organisation = create(:organisation, content_items: content_items)

      results = subject.new(organisation: organisation, taxonomy: taxonomy, query: "title 1").results

      expect(results).to match_array(content_items)
    end
  end

  describe "paging results" do
    before do
      Kaminari.configure do |config|
        @default_per_page = config.default_per_page
        config.default_per_page = 1
      end
    end

    it "limits the number of items returned to the maximum per page" do
      create_list(:content_item, 2)

      results = subject.new({}).paginated_results

      expect(results.count).to eq(1)
    end

    it "gives the correct page of the results" do
      create_list(:content_item, 2)

      results = subject.new(page: 2).paginated_results

      expect(results.count).to eq(1)
    end
  end
end
