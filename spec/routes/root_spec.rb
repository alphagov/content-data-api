require 'rails_helper'

RSpec.describe "App index", type: :routing do
  it 'the app index routes to content_items#index' do
    expect(get: '/').to route_to('content_items#index')
  end
end
