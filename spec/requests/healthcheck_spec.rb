RSpec.describe '/healthcheck' do
  it 'returns distinct organisations ordered by title' do
    get '/healthcheck'
    json = JSON.parse(response.body)

    expect(json['checks']).to include('database_status').
      and(include('etl_google_analytics_pviews')).
      and(include('etl_google_analytics_upviews'))
  end

  it "is not cacheable" do
    get "/healthcheck"

    expect(response.headers['Cache-Control']).to eq "max-age=0, private, must-revalidate"
  end
end
