require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe Items::PreloadItemsProcessor do
  include GdsApi::TestHelpers::PublishingApiV2
  subject { described_class }
  let(:fields) { %i[base_path content_id locale] }
  let(:content_items) do
    [
      {
        content_id: 'abc123',
        base_path: '/abc',
        description: 'Description of content with the title of abc.',
        title: 'abc',
        locale: 'en',
      },
      {
        content_id: 'xyz789',
        base_path: '/xyz',
        description: 'Description of content with the title of xyz.',
        title: 'xyz',
        locale: 'en',
      }
    ]
  end

  before :each do
    publishing_api_get_editions(content_items, fields: fields, per_page: 50, states: ['published'])
    allow(Items::Jobs::ImportContentDetailsJob).to receive(:perform_async)
    subject.process
  end

  it 'saves an item per entry in Search API' do
    expect(Dimensions::Item.count).to eq(2)
  end

  it 'transform an entry in PublishingAPI into a Dimensions::Item' do
    item = Dimensions::Item.find_by(content_id: 'xyz789')
    expect(item).to have_attributes(
      content_id: 'xyz789',
      base_path: '/xyz',
      latest: true
    )
  end

  it 'creates a ImportItemJob for each item' do
    item = Dimensions::Item.find_by(content_id: 'xyz789')
    expect(Items::Jobs::ImportContentDetailsJob).to have_received(:perform_async).with(item.id)


    item2 = Dimensions::Item.find_by(content_id: 'abc123')
    expect(Items::Jobs::ImportContentDetailsJob).to have_received(:perform_async).with(item2.id)
  end
end
