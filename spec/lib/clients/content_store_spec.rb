require 'rails_helper'

RSpec.describe Clients::ContentStore do
  it 'queries the content item API with base path' do
    response = double(body: {}.to_json)
    expected_url = 'https://www.gov.uk/api/content/the-path'
    expect(HTTParty).to receive(:get).with(expected_url).and_return(response)

    subject.fetch('/the-path', Array.new)
  end

  it 'returns the content item attributes' do
    response = double(body: { param1: :value1, param2: :value2 }.to_json)
    expect(HTTParty).to receive(:get).and_return(response)

    expect(subject.fetch('/the-path', ['param2'])).to eq('param2' => 'value2')
  end
end
