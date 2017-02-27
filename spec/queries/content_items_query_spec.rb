require 'rails_helper'

RSpec.describe ContentItemsQuery, type: :query do
  subject { described_class }

  context "sorts with parameters" do
    let!(:content_items) do
      [
        create(:content_item, id: 1, public_updated_at: Time.parse("2016-12-09")),
        create(:content_item, id: 2, public_updated_at: Time.parse("2015-12-09"))
      ]
    end

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

    describe "filtering by organisation" do
      let(:organisation) { create(:organisation, content_items: content_items) }

      it 'returns the content items belonging to the organisation' do
        create(:content_item)
        results = subject.build(organisation: organisation)

        expect(results).to match_array(content_items)
      end
    end
  end
end
