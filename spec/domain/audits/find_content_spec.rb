module Audits
  RSpec.describe FindContent do
    let!(:content_items) { create_list(:content_item, 210) }
    let!(:user) { create(:user) }

    describe '#all' do
      subject(:relation) { described_class.all(filter) }

      let(:filter) { Filter.new(allocated_to: 'anyone') }

      it 'returns all filtered content items' do
        expect(relation).to match_array(content_items)
      end
    end

    describe '#batch' do
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

    describe '#paged' do
      subject(:relation) { described_class.paged(filter) }

      let(:filter) do
        Filter.new(allocated_to: 'anyone', sort: 'id', sort_direction: 'asc',
                   page: 3, per_page: 10)
      end

      it 'returns the next page of filtered content items' do
        expect(relation)
          .to match_array(content_items.sort_by(&:id)[20...30])
      end
    end

    describe '#my_content' do
      subject(:relation) { described_class.my_content(user.uid) }

      before do
        Audits::Allocation.create(uid: user.uid, content_id: Content::Item.first.content_id)
        Audits::Allocation.create(uid: user.uid, content_id: Content::Item.second.content_id)
        Audits::Allocation.create(uid: user.uid, content_id: Content::Item.third.content_id)
      end

      it 'returns my content' do
        expect(relation).to match_array(content_items.sort_by(&:id)[0...3])
      end
    end

    describe '#query' do
      subject(:relation) { described_class.query(filter) }

      before { allow(Content::Query).to receive(:new) { query } }

      let(:filter) { Filter.new(allocated_to: 'anyone') }
      let(:query) { spy('Content::Query') }

      it 'returns a content query based on the supplied filter' do
        relation

        expect(query).to have_received(:after).with(filter.after)
        expect(query).to have_received(:document_types).with(*Plan.document_type_ids)
        expect(query).to have_received(:document_types).with(filter.document_type)
        expect(query).to have_received(:organisations).with(filter.organisations, filter.primary_org_only)
        expect(query).to have_received(:page).with(filter.page)
        expect(query).to have_received(:per_page).with(filter.per_page)
        expect(query).to have_received(:sort).with(filter.sort)
        expect(query).to have_received(:sort_direction).with(filter.sort_direction)
        expect(query).to have_received(:title).with(filter.title)
      end
    end
  end
end
