RSpec.describe Api::ContentRequest do
  describe '#to_filter' do
    it 'returns a hash with the parameters' do
      request = Api::ContentRequest.new(
        document_type: 'guide',
        organisation_id: 'the-id',
        page: '1',
        page_size: '20',
        date_range: 'last-30-days',
      )

      expect(request.to_filter).to eq(
        document_type: 'guide',
        organisation_id: 'the-id',
        page: 1,
        page_size: 20,
        date_range: 'last-30-days',
      )
    end

    it 'includes missing parameters' do
      request = Api::ContentRequest.new(
        document_type: nil,
        organisation_id: nil,
      )

      expect(request.to_filter).to eq(
        document_type: nil,
        organisation_id: nil,
        page: nil,
        page_size: nil,
        date_range: nil,
      )
    end
  end
end
