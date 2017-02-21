require 'rails_helper'

RSpec.describe Importers::AllTaxons do
  describe '#run' do
    it 'creates a new Taxonomy if not present' do
      attrs1 = { content_id: 'a-content-item_-1', title: 'a-title-1' }
      attrs2 = { content_id: 'a-content-item_-2', title: 'a-title-2' }
      subject.taxonomies_service = double
      
      allow(subject.taxonomies_service).to receive(:find_each).and_yield(attrs1).and_yield(attrs2)

      expect { subject.run }.to change { Taxonomy.count }.by(2)
    end

    context 'when the taxonomy exists' do
      before { create :taxonomy, title: 'old-title' }

      it 'updates the attributes' do
        attrs1 = { content_id: 'a-content-id-1', title: 'a-title-1' }
        subject.taxonomies_service = double

        allow(subject.taxonomies_service).to receive(:find_each).and_yield(attrs1)
        
        subject.run

        taxon = Taxonomy.find_by(content_id: 'a-content-id-1')
        expect(taxon.title).to eq('a-title-1')
      end
    end
  end
end
