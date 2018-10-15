RSpec.describe Queries::FindAllDocumentTypes do
  context 'when we have data' do
    before do
      create :user
      create :edition, document_type: 'guide', latest: true
      create :edition, document_type: 'travel_advice', latest: true
      create :edition, document_type: 'manual', latest: true
      create :edition, document_type: 'service-manual', latest: false
    end

    it 'returns distinct document types of latest editions' do
      results = described_class.retrieve
      expect(results.pluck(:document_type)).to eq(%w(guide manual travel_advice))
    end

    it 'does not return document types of editions that are not the latest' do
      results = described_class.retrieve
      expect(results.pluck(:document_type)).to_not include('service-manual')
    end
  end

  context 'when there is no data' do
    it 'returns an empty array' do
      expect(described_class.retrieve).to eq([])
    end
  end
end
