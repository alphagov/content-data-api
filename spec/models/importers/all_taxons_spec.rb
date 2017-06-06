RSpec.describe Importers::AllTaxons do
  describe '#run' do
    it 'creates a new Taxon if not present' do
      attrs1 = { content_id: 'a-content-item_-1', title: 'a-title-1' }
      attrs2 = { content_id: 'a-content-item_-2', title: 'a-title-2' }
      subject.taxons = double

      allow(subject.taxons).to receive(:find_each).and_yield(attrs1).and_yield(attrs2)

      expect { subject.run }.to change { Taxon.count }.by(2)
    end

    context 'when the taxon exists' do
      before { create :taxon, title: 'old-title' }

      it 'updates the attributes' do
        attrs1 = { content_id: 'a-content-id-1', title: 'a-title-1' }
        subject.taxons = double

        allow(subject.taxons).to receive(:find_each).and_yield(attrs1)

        subject.run

        taxon = Taxon.find_by(content_id: 'a-content-id-1')
        expect(taxon.title).to eq('a-title-1')
      end
    end
  end
end
