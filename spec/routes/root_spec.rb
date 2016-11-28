require 'rails_helper'

RSpec.describe OrganisationsController, type: :routing do
  describe 'routing' do
    it 'routes to organisations#index' do
      expect(get: '/').to route_to('organisations#index')
    end
  end
end
