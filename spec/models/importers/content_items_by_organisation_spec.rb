require 'rails_helper'

RSpec.describe Importers::ContentItemsByOrganisation do
  describe '#run' do
    let!(:organisation) { create(:organisation, slug: 'the-slug') }
    let!(:content_item) { create(:content_item, content_id: 'the-content-id', organisations: [organisation]) }

    it 'update the metrics of the content item' do
      subject.metric_builder = double(run_all: { number_of_pdfs: 10 })
      subject.content_items_service = double
      attrs1 = { content_id: 'the-content-id', taxons: [] }
      allow(subject.content_items_service).to receive(:find_each).with('the-slug').and_yield(attrs1)

      subject.run('the-slug')

      expect(content_item.reload.number_of_pdfs).to eq(10)
    end

    it 'creates a new content item and updates an existing one in the same import' do
      subject.metric_builder = double(run_all: {})
      subject.content_items_service = double
      attrs1 = { content_id: 'the-content-id', taxons: [] }
      attrs2 = { content_id: 'the-content-id2', taxons: [] }
      allow(subject.content_items_service).to receive(:find_each).with('the-slug').and_yield(attrs1).and_yield(attrs2)

      expect { subject.run('the-slug') }.to change { ContentItem.count }.by(1)
    end
  end
end
