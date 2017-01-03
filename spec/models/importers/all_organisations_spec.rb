require 'rails_helper'

RSpec.describe Importers::AllOrganisations do
  describe '#run' do
    context 'when the organisation does not exist' do
      it 'creates an organisation per attribute group' do
        attrs1 = { slug: 'a-slug-1', title: 'a-title-1' }
        attrs2 = { slug: 'a-slug-2', title: 'a-title-2' }
        allow_any_instance_of(OrganisationsService).to receive(:find_each).and_yield(attrs1).and_yield(attrs2)

        expect { subject.run }.to change { Organisation.count }.by(2)
      end

      it 'updates the attributes' do
        attrs1 = { slug: 'a-slug-1', title: 'a-title-1' }
        allow_any_instance_of(OrganisationsService).to receive(:find_each).and_yield(attrs1)
        subject.run

        attributes = Organisation.find_by(slug: 'a-slug-1').attributes.symbolize_keys
        expect(attributes).to include(slug: 'a-slug-1', title: 'a-title-1')
      end
    end

    context 'when the organisation already exists' do
      let(:organisation) { create(:organisation, slug: 'the-slug') }

      it 'does not create a new one' do
        attributes = { slug: organisation.slug, title: 'some-title' }
        allow_any_instance_of(OrganisationsService).to receive(:find_each).and_yield(attributes)

        expect { subject.run }.to change { Organisation.count }.by(0)
      end

      it 'updates the attributes' do
        organisation.update(title: 'a-title')
        allow_any_instance_of(OrganisationsService).to receive(:find_each).and_yield(slug: organisation.slug, title: 'new-title')
        subject.run

        expect(Organisation.first.title).to eq('new-title')
      end
    end
  end
end
