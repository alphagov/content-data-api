require 'rails_helper'

RSpec.describe OrganisationsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/organisations').to route_to('organisations#index')
    end
  end
end