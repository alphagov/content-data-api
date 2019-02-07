RSpec.describe Api::ContentRequest do
  let(:params) { { date_range: 'past-30-days', organisation_id: 'all' } }

  describe '#to_filter' do
    it 'returns a hash with the parameters' do
      request = Api::ContentRequest.new(
        document_type: 'guide',
        organisation_id: 'the-id',
        search_term: 'a title or url',
        page: '1',
        page_size: '20',
        date_range: 'past-30-days',
        sort: 'feedex:asc'
      )

      expect(request.to_filter).to eq(
        document_type: 'guide',
        organisation_id: 'the-id',
        search_term: 'a title or url',
        page: 1,
        page_size: 20,
        date_range: 'past-30-days',
        sort_attribute: 'feedex',
        sort_direction: 'asc'
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
        search_term: nil,
        page_size: nil,
        date_range: nil,
        sort_attribute: nil,
        sort_direction: nil
      )
    end

    allowed_sort_attributes = %w[
      title document_type upviews pviews useful_yes useful_no searches feedex pdf_count words
    ]

    allowed_sort_attributes.each do |attribute|
      it "allows #{attribute} as sort attribute" do
        request = Api::ContentRequest.new(params.merge(sort: attribute))

        expect(request.to_filter).to include(sort_attribute: attribute, sort_direction: nil)
      end
    end

    it 'allows a valid sort attribute with asc direction' do
      request = Api::ContentRequest.new(params.merge(sort: 'feedex:asc'))

      expect(request.to_filter).to include(sort_attribute: 'feedex', sort_direction: 'asc')
    end

    it 'allows a valid sort attribute with desc direction' do
      request = Api::ContentRequest.new(params.merge(sort: 'feedex:desc'))

      expect(request.to_filter).to include(sort_attribute: 'feedex', sort_direction: 'desc')
    end

    describe '#sort_attribute' do
      it 'validates value' do
        request = Api::ContentRequest.new(params.merge(sort: 'invalid'))
        request.valid?
        expect(request.errors[:sort]).to include("this is not a valid sort attribute")
      end

      it 'validates presence' do
        request = Api::ContentRequest.new(params.merge(sort: ':desc'))
        request.valid?
        expect(request.errors[:sort]).to include("this is not a valid sort attribute")
      end
    end

    describe '#sort_direction' do
      it 'validates value' do
        request = Api::ContentRequest.new(params.merge(sort: 'feedex:invalid'))
        request.valid?
        expect(request.errors[:sort]).to include("this is not a valid sort direction")
      end

      it 'validates presence' do
        request = Api::ContentRequest.new(params.merge(sort: 'feedex:'))
        request.valid?
        expect(request.errors[:sort]).to include("this is not a valid sort direction")
      end
    end
  end
end
