require 'rails_helper'

RSpec.describe ContentItemsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: organisation_content_items_path('a-slug')).to be_routable
      expect(get: organisation_content_items_path('a-slug'))
        .to route_to(
          controller: 'content_items',
          action: 'index',
          organisation_slug: 'a-slug'
        )
    end

    it 'routes to #show' do
      expect(get: organisation_content_item_path(organisation_slug: 'a-slug', id: 1)).to be_routable
      expect(get: organisation_content_item_path(organisation_slug: 'a-slug', id: 1))
        .to route_to(
          controller: 'content_items',
          action: 'show',
          organisation_slug: 'a-slug',
          id: '1',
        )
    end
  end
end
