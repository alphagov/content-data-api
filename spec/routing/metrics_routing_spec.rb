RSpec.describe 'metrics routing' do
  it 'routes /api/v1/metrics/:metric/long/base/path correctly' do
    expect(get: '/api/v1/metrics/long/base/path').to route_to(
      controller: 'api/metrics',
      action: 'summary',
      format: :json,
      base_path: 'long/base/path'
    )
  end

  it 'routes /api/v1/metrics/:metric/long/base/path/time-series correctly' do
    expect(get: '/api/v1/metrics/long/base/path/time-series').to route_to(
      controller: 'api/metrics',
      action: 'time_series',
      format: :json,
      base_path: 'long/base/path'
    )
  end
end
