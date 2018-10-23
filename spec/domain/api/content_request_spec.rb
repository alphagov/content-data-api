RSpec.describe Api::ContentRequest do
  it '#to_filter' do
    request = Api::ContentRequest.new(
      document_type: 'guide',
      organisation_id: 'the-id',
      from: '2018-01-01',
      to: '2018-01-31'
    )

    expect(request.to_filter).to eq(
      document_type: 'guide',
      organisation_id: 'the-id',
      from: '2018-01-01',
      to: '2018-01-31'
    )
  end
end
