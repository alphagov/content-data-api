module Audits
  RSpec.describe FindNextItem do
    subject(:next_item) { described_class.call(current_content_item, filter) }

    let(:current_content_item) { content_items[5] }
    let(:content_items) { create_list(:content_item, 10).sort_by(&:id) }

    let(:filter) do
      Filter.new(
        allocated_to: 'anyone',
        sort: 'id',
        sort_direction: :asc,
      )
    end

    it 'returns the next filtered content item relative to the supplied item' do
      expect(next_item).to eq(content_items[6])
    end
  end
end
