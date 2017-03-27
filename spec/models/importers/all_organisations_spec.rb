require 'rails_helper'

RSpec.describe Importers::AllOrganisations do
  describe '#run' do
    context 'when the organisation does not exist' do
      it 'creates an organisation per attribute group' do
        attrs1 = { slug: 'a-slug-1', title: 'a-title-1', content_id: "content-item-1" }
        attrs2 = { slug: 'a-slug-2', title: 'a-title-2', content_id: "content-item-2" }
        allow_any_instance_of(OrganisationsService).to receive(:find_each).and_yield(attrs1).and_yield(attrs2)

        expect { subject.run }.to change { Organisation.count }.by(2)
      end

      it 'updates the attributes' do
        attrs1 = { slug: 'a-slug-1', title: 'a-title-1', content_id: "content-item-1" }
        allow_any_instance_of(OrganisationsService).to receive(:find_each).and_yield(attrs1)
        subject.run

        attributes = Organisation.find_by(content_id: 'content-item-1').attributes.symbolize_keys
        expect(attributes).to include(slug: 'a-slug-1', title: 'a-title-1')
      end
    end

    context 'when the organisation already exists' do
      let!(:organisation) { create(:organisation, content_id: "content-item-1") }

      it 'does not create a new one' do
        attributes = { slug: 'a-slug', title: 'some-title', content_id: "content-item-1" }
        allow_any_instance_of(OrganisationsService).to receive(:find_each).and_yield(attributes)

        expect { subject.run }.to change { Organisation.count }.by(0)
      end

      it 'updates the attributes' do
        organisation.update(title: 'a-title')
        allow_any_instance_of(OrganisationsService).to receive(:find_each).and_yield(slug: organisation.slug, title: 'new-title', content_id: "content-item-1")
        subject.run

        expect(Organisation.first.title).to eq('new-title')
      end
    end
  end
end
