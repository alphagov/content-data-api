RSpec.shared_examples "API response" do |path, params = {}|
  it "should be cacheable until the end of the day" do
    Timecop.freeze(Time.zone.local(2020, 1, 1, 0, 0, 0)) do
      get(path, params:)

      expect(response.headers["ETag"]).to be_present
      expect(response.headers["Cache-Control"]).to eq "max-age=3600, public"
    end
  end

  it "expires at 1am" do
    Timecop.freeze(Time.zone.local(2020, 1, 1, 1, 0, 0)) do
      get(path, params:)

      expect(response.headers["ETag"]).to be_present
      expect(response.headers["Cache-Control"]).to eq "max-age=0, public"
    end
  end

  it "can be cached for up to a day" do
    Timecop.freeze(Time.zone.local(2020, 1, 1, 1, 0, 1)) do
      get(path, params:)

      expect(response.headers["ETag"]).to be_present
      expect(response.headers["Cache-Control"]).to eq "max-age=86399, public"
    end
  end
end
