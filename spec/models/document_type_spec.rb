RSpec.describe DocumentType do
  describe '.find_all' do
    it 'returns a list of document types' do
      create(:edition, document_type: 'news_story')
      create(:edition, document_type: 'guide')

      expect(DocumentType.find_all).to all(be_a(DocumentType))
    end

    it 'filter irrelevent document types' do
      create(:edition, document_type: 'guide')
      create(:edition, document_type: 'redirect')
      create(:edition, document_type: 'gone')
      create(:edition, document_type: 'vanish')
      create(:edition, document_type: 'unpublishing')
      create(:edition, document_type: 'need')

      expect(DocumentType.find_all).to match_array([
        have_attributes(id: 'guide')
      ])
    end

    it 'humanizes document type names' do
      create(:edition, document_type: 'news_story')
      create(:edition, document_type: 'aaib_report')

      expect(DocumentType.find_all).to match_array([
        have_attributes(name: 'News story'),
        have_attributes(name: 'AAIB report')
      ])
    end
  end
end
