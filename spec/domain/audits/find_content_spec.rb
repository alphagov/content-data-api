module Audits
  RSpec.describe FindContent do
    describe '#batch' do
      let!(:content_items) { create_list(:content_item, 210) }

      let(:batch_size) { 105 }
      let(:filter) { Filter.new(sort: 'id', sort_direction: 'asc') }
      let(:from_page) { 2 }

      subject(:relation) {
        described_class.batch(
          filter,
          batch_size: batch_size,
          from_page: from_page,
        )
      }

      it 'returns a batch of filtered content items offset from the given page' do
        expect(relation)
          .to match_array(content_items.sort_by(&:id)[100...205])
      end
    end
  end
end
