RSpec.describe '/document_types' do
  before do
    create :user
    create :edition, document_type: 'guide'
    create :edition, document_type: 'manual'
    create :edition, document_type: 'manual'
  end

  it 'returns distinct document types ordered by title' do
    get '/document_types'
    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json).to eq(document_types: %w(guide manual))
  end

  describe "an API response" do
    it "should be cacheable until the end of the day" do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 0, 0, 0)) do
        get "/document_types"

        expect(response.headers['ETag']).to be_present
        expect(response.headers['Cache-Control']).to eq "max-age=3600, public"
      end
    end

    it "expires at 1am" do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 1, 0, 0)) do
        get '/document_types'

        expect(response.headers['ETag']).to be_present
        expect(response.headers['Cache-Control']).to eq "max-age=0, public"
      end
    end

    it "can be cached for up to a day" do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 1, 0, 1)) do
        get '/document_types'

        expect(response.headers['ETag']).to be_present
        expect(response.headers['Cache-Control']).to eq "max-age=86399, public"
      end
    end
  end
end
