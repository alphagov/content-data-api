require 'rails_helper'

RSpec.describe Importers::AllContentItems do
  describe '#run' do
    let!(:content_item) { create(:content_item, content_id: 'the-id') }

    it 'imports content items for all document types' do
      subject.document_types = %w(type_1 type_2)
      subject.content_items_service = double

      expect(subject.content_items_service).to receive(:find_each).with("type_1")
      expect(subject.content_items_service).to receive(:find_each).with("type_2")

      subject.run
    end

    it 'creates a new content item and updates an existing one in the same import' do
      subject.content_items_service = double
      subject.metric_builder = double(run_all: {})
      attrs1 = { content_id: 'the-id', taxons: [], organisations: [] }
      attrs2 = { content_id: 'the-id-2', taxons: [], organisations: [] }
      allow(subject.content_items_service).to receive(:find_each).and_yield(attrs1).and_yield(attrs2)

      expect { subject.run }.to change { ContentItem.count }.by(1)
    end

    it 'update the metrics of the content item' do
      subject.document_types = ["type_1"]
      subject.content_items_service = double
      subject.metric_builder = double(run_all: { number_of_pdfs: 10 })
      attrs = { content_id: 'the-id', taxons: [], organisations: [] }

      allow(subject.content_items_service).to receive(:find_each).and_yield(attrs)

      subject.run

      expect(content_item.reload.number_of_pdfs).to eq(10)
    end

    it 'does not import content items if there are no document types' do
      subject.document_types = []
      expect(subject.content_items_service).not_to receive(:find_each)

      subject.run
    end
  end
end
