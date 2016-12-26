require 'rails_helper'

RSpec.describe Clients::ContentStore do
  subject { Clients::ContentStore }

  it 'queries the content item API with base path' do
    response = double(body: {}.to_json)
    expected_url = 'https://www.gov.uk/api/content/the-path'
    expect(HTTParty).to receive(:get).with(expected_url).and_return(response)

    subject.find('/the-path', Array.new)
  end

  it 'returns the content item attributes' do
    response = double(body: { param1: :value1, param2: :value2 }.to_json)
    expect(HTTParty).to receive(:get).and_return(response)

    expect(subject.find('/the-path', %i(param2))).to eq(param2: 'value2')
  end
end
