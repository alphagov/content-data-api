RSpec.describe '/organisations' do
  before do
    create :user
    create :edition, organisation_id: 'org-1-id', primary_organisation_title: 'z Org'
    create :edition, organisation_id: 'org-1-id', primary_organisation_title: 'z Org'
    create :edition, organisation_id: 'org-2-id', primary_organisation_title: 'a Org'
  end

  it 'returns distinct organisations ordered by title' do
    get '/organisations'
    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json).to eq(
      organisations: [
        { title: 'a Org', organisation_id: 'org-2-id' },
        { title: 'z Org', organisation_id: 'org-1-id' }
      ]
    )
  end

  describe "an API response" do
    it "should be cacheable until the end of the day" do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 0, 0, 0)) do
        get '/organisations'

        expect(response.headers['ETag']).to be_present
        expect(response.headers['Cache-Control']).to eq "max-age=3600, public"
      end
    end

    it "expires at 1am" do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 1, 0, 0)) do
        get '/organisations'

        expect(response.headers['ETag']).to be_present
        expect(response.headers['Cache-Control']).to eq "max-age=0, public"
      end
    end

    it "can be cached for up to a day" do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 1, 0, 1)) do
        get '/organisations'

        expect(response.headers['ETag']).to be_present
        expect(response.headers['Cache-Control']).to eq "max-age=86399, public"
      end
    end
  end
end
