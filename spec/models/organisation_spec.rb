require 'rails_helper'

RSpec.describe Organisation, type: :model do
  it { should have_many(:content_items) }

  describe '#total_content_items' do
    it 'returns the total content items' do
      organisation = create(:organisation_with_content_items, slug: 'a_slug', content_items_count: 2)

      expect(organisation.total_content_items).to eq(2)
    end
  end

  it 'returns the organisation name' do
    organisation = build(:organisation, slug: 'a-name')

    expect(organisation.name).to eq('A Name')
  end
end
