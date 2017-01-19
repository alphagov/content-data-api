require 'rails_helper'

RSpec.describe Clients::ContentStore do
  subject { Clients::ContentStore }

  it 'queries the content item API with base path' do
    stub_request(:get, %r{/the-path}).to_return(status: 200, body:  {}.to_json)

    subject.find('/the-path', Array.new)

    expect(WebMock).to have_requested(:get, %r{/the-path})
  end

  it 'returns the content item attributes' do
    stub_request(:get, %r{/the-path}).to_return(
      status: 200,
      body:  { param1: :value1, param2: :value2 }.to_json
    )

    expect(subject.find('/the-path', %i(param2))).to eq(param2: 'value2')
  end

  it "returns nil when a content item is not found" do
    stub_request(:get, %r{/does-not-exist}).to_return(
      status: 404,
      body: "Not Found"
    )

    expect(subject.find('/does-not-exist', Array.new)).to eq(nil)
  end
end
