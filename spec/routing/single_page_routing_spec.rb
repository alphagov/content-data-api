RSpec.describe 'single page endpoint routing' do
  it 'routes /single-item/very/long/base/path' do
    expect(get: '/single_page/very/long/base/path').to route_to(
      controller: 'single_item',
      action: 'show',
      format: :json,
      base_path: 'very/long/base/path'
    )
  end

  it 'routes /single_page (for the homepage)' do
    expect(get: '/single_page/').to route_to(
      controller: 'single_item',
      action: 'show',
      format: :json
    )
  end
end
