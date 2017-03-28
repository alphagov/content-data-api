require 'rails_helper'

RSpec.describe ContentItemsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: content_items_path).to be_routable
      expect(get: content_items_path)
        .to route_to(
          controller: 'content_items',
          action: 'index'
        )
    end

    it 'routes to #show' do
      expect(get: content_item_path(id: 1)).to be_routable
      expect(get: content_item_path(id: 1))
        .to route_to(
          controller: 'content_items',
          action: 'show',
          id: '1',
        )
    end
  end
end
