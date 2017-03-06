require 'rails_helper'

RSpec.describe Importers::ContentItemsByOrganisation do
  describe '#run' do
    let!(:organisation) { create(:organisation, slug: 'the-slug') }
    let(:content_item) { create(:content_item, base_path: 'the-link', organisations: [organisation]) }

    context 'when the content item does not exist' do
      it 'creates a content item per attribute group' do
        attrs1 = attributes_for(:content_item)
        attrs2 = attributes_for(:content_item)
        subject.metric_builder = double()

        allow_any_instance_of(ContentItemsService).to receive(:find_each).with('the-slug').and_yield(attrs1).and_yield(attrs2)
        allow(subject.metric_builder).to receive(:run_all).and_return({})

        expect { subject.run('the-slug') }.to change { ContentItem.count }.by(2)
      end

      it 'updates the attributes' do
        attrs1 = attributes_for(:content_item, base_path: 'the-link-value', title: 'the-title')
        subject.metric_builder = double()

        allow_any_instance_of(ContentItemsService).to receive(:find_each).and_yield(attrs1)
        allow(subject.metric_builder).to receive(:run_all).and_return({})

        subject.run('the-slug')

        attributes = ContentItem.find_by(base_path: 'the-link-value').attributes.symbolize_keys
        expect(attributes).to include(title: 'the-title')
      end
    end

    context 'when the content item already exists' do
      let(:content_item) { create(:content_item, base_path: 'the-link', organisations: [organisation]) }

      it 'does not create a new one' do
        attributes = { content_id: content_item.content_id, base_path: 'the-link' }
        subject.metric_builder = double()

        allow_any_instance_of(ContentItemsService).to receive(:find_each).and_yield(attributes)
        allow(subject.metric_builder).to receive(:run_all).and_return({})

        expect { subject.run('the-slug') }.to change { ContentItem.count }.by(0)
      end

      it 'updates the attributes' do
        content_item.update(title: 'old-title')
        attributes = { content_id: content_item.content_id, title: 'the-new-title', base_path: 'the-link' }
        subject.metric_builder = double()

        allow_any_instance_of(ContentItemsService).to receive(:find_each).and_yield(attributes)
        allow(subject.metric_builder).to receive(:run_all).and_return({})

        subject.run('the-slug')

        expect(ContentItem.first.title).to eq('the-new-title')
      end
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
