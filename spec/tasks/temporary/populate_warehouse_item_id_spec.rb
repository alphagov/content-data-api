RSpec.describe 'rake warehouse_item_id:populate', type: task do
  include ItemSetupHelpers

  before do
    create :dimensions_item,
      content_id: 'cont-1',
      base_path: '/path/1',
      locale: 'en',
      document_type: 'guide'
    create :dimensions_item,
      base_path: '/path/2',
      content_id: 'cont-2',
      locale: 'en',
      document_type: 'travel_advice'
    create :dimensions_item,
      base_path: '/path/3',
      content_id: 'cont-3',
      locale: 'fr',
      document_type: 'news_story'
  end

  it 'creates a content_id for all items' do
    Rake::Task['warehouse_item_id:populate'].invoke
    all_items = Dimensions::Item.pluck(:base_path, :warehouse_item_id)
    expect(all_items).to eq([
      %w(/path/1 cont-1:en:/path/1),
      %w(/path/2 cont-2:en:/path/2),
      %w(/path/3 cont-3:fr)
    ])
  end
end
