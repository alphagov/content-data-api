require 'rails_helper'

RSpec.describe ContentItem, type: :model do
  it { should belong_to(:organisation) }

  describe '#url' do
    it 'returns a url to a content item on gov.uk' do
      content_item = build(:content_item, base_path: '/api/content/item/path/1')
      expect(content_item.url).to eq('https://gov.uk/api/content/item/path/1')
    end
  end
end
