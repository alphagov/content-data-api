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
      expect(get: content_item_path(content_id: "content-id-123")).to be_routable
      expect(get: content_item_path(content_id: "content-id-123"))
        .to route_to(
          controller: 'content_items',
          action: 'show',
          content_id: 'content-id-123',
        )
    end

    it 'routes to #filter' do
      expect(get: filter_content_items_path).to be_routable
      expect(get: filter_content_items_path)
        .to route_to(
          controller: 'content_items',
          action: 'filter'
        )
    end
  end
end
