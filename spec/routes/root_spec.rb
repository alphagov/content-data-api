require 'rails_helper'

RSpec.describe OrganisationsController, type: :routing do
  describe 'routing' do
    it 'routes to organisations#index' do
      expect(get: '/').to route_to('organisations#index')
    end

    it 'routes to content_items#index' do
      expect(get: '/content_items').to route_to('content_items#index')
    end
  end
end
