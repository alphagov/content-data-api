require 'rails_helper'

RSpec.describe ContentItemsQuery, type: :query do
  subject { described_class }
  let!(:content_items) do
    [
      create(:content_item, id: 1, public_updated_at: Time.parse("2016-12-09")),
      create(:content_item, id: 2, public_updated_at: Time.parse("2015-12-09"))
    ]
  end

  context "search title" do
    let!(:content_items) do
      [
        create(:content_item, title: 'title 1'),
        create(:content_item, title: 'title 2')
      ]
    end

    it "returns content_items case insensitively" do
      results = subject.build(query: 'TITLE 1')

      expect(results.count).to eq(1)
      expect(results.first.title).to eq('title 1')
    end
  end

  context "sorts with parameters" do
    context "in ascending order" do
      it "returns content_items" do
        results = subject.build(sort: :public_updated_at, order: :asc)

        expect(results.pluck(:id)).to eq([2, 1])
      end
    end

    context "in descending order" do
      it "returns content_items" do
        results = subject.build(sort: :public_updated_at, order: :desc)

        expect(results.pluck(:id)).to eq([1, 2])
      end
    end
  end

  describe "filtering" do
    context "by organisation" do
      let(:organisation) { create(:organisation, content_items: content_items) }

      it "returns the content items belonging to the organisation" do
        create(:content_item)
        results = subject.build(organisation: organisation)

        expect(results).to match_array(content_items)
      end
    end

    context "by taxonomy" do
      let(:taxonomy) { create(:taxonomy, content_items: content_items) }

      it "returns the content items belonging to the taxonomy" do
        create(:content_item)
        results = subject.build(taxonomy: taxonomy)

        expect(results).to match_array(content_items)
      end
    end

    context "by organisation and taxonomy" do
      let(:organisation) { create(:organisation, content_items: content_items) }
      let(:taxonomy) { create(:taxonomy, content_items: content_items) }

      it "returns the content items belonging to the organisation and taxonomy" do
        create(:content_item)
        results = subject.build(organisation: organisation, taxonomy: taxonomy)

        expect(results).to match_array(content_items)
      end
    end

    context "by organisation and taxonomy and search term" do
      let(:content_item) { create(:content_item, title: "title 1") }
      let(:organisation) { create(:organisation, content_items: [content_item]) }
      let(:taxonomy) { create(:taxonomy, content_items: [content_item]) }

      it "returns the content items belonging to the organisation and taxonomy" do
        results = subject.build(organisation: organisation, taxonomy: taxonomy, query: "title 1")

        expect(results).to match_array([content_item])
      end
    end
  end
end
