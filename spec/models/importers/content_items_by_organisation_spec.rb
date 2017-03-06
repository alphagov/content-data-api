require 'rails_helper'

RSpec.describe Importers::ContentItemsByOrganisation do
  describe '#run' do
    let!(:organisation) { create(:organisation, slug: 'the-slug') }
    let!(:content_item) { create(:content_item, content_id: 'the-content-id', organisations: [organisation]) }

    it 'creates or update all the content items' do
      subject.metric_builder = double(run_all: {})
      attrs1 = { content_id: 'the-content-id' }
      attrs2 = { content_id: 'the-content-id2' }
      allow_any_instance_of(ContentItemsService).to receive(:find_each).with('the-slug').and_yield(attrs1).and_yield(attrs2)

      expect { subject.run('the-slug') }.to change { ContentItem.count }.by(1)
    end

    it 'calls the metric builder for each content item' do
      attrs1 = attributes_for(:content_item)
      attrs2 = attributes_for(:content_item)
      subject.metric_builder = double()

      allow_any_instance_of(ContentItemsService).to receive(:find_each).with('the-slug').and_yield(attrs1).and_yield(attrs2)
      allow(subject.metric_builder).to receive(:run_all).and_return({})
      
      expect(subject.metric_builder).to receive(:run_all).twice

      subject.run('the-slug')
    end
  end
end
