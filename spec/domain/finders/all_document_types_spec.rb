RSpec.describe Finders::AllDocumentTypes do
  subject { described_class }

  describe '.find_all' do
    it 'returns a list of document types' do
      create(:edition, document_type: 'news_story')
      create(:edition, document_type: 'guide')

      expect(subject.run).to all(be_a(DocumentType))
    end

    it 'filter irrelevent document types' do
      create(:edition, document_type: 'guide')
      create(:edition, document_type: 'redirect')
      create(:edition, document_type: 'gone')
      create(:edition, document_type: 'vanish')
      create(:edition, document_type: 'unpublishing')
      create(:edition, document_type: 'need')

      expect(subject.run).to match_array([
        have_attributes(id: 'guide')
      ])
    end

    it 'humanizes document type names' do
      create(:edition, document_type: 'news_story')
      create(:edition, document_type: 'aaib_report')

      expect(subject.run).to match_array([
        have_attributes(name: 'News story'),
        have_attributes(name: 'AAIB report')
      ])
    end

    it 'sorts result by name' do
      create(:edition, document_type: 'news_story')
      create(:edition, document_type: 'aaib_report')

      expect(subject.run).to be_sorted_by(&:name)
    end

    it 'returns only document types of live editions' do
      create(:edition, document_type: 'news_story')
      create(:edition, document_type: 'guidance', live: false)

      expect(subject.run).to match_array([
        have_attributes(id: 'news_story'),
      ])
    end

    it 'returns an empty array when no data' do
      expect(described_class.run).to eq([])
    end
  end
end
