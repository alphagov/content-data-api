require 'rails_helper'

RSpec.describe Organisation, type: :model do
  it { should have_many(:content_items) }

  describe '#total_content_items' do
    it 'returns the total content items' do
      content_item1 = ContentItem.new
      content_item2 = ContentItem.new
      organisation = Organisation.create!(slug: 'a_slug', content_items: [content_item1, content_item2])

      expect(organisation.total_content_items).to eq(2)
    end
  end
end
