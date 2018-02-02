require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe ETL::Items do
  include GdsApi::TestHelpers::PublishingApiV2
  subject { described_class }
  let(:fields) { %i[base_path content_id description title] }
  let(:content_items) do
    [
      {
        content_id: 'abc123',
        base_path: '/abc',
        description: 'Description of content with the title of abc.',
        title: 'abc'
      },
      {
        content_id: 'xyz789',
        base_path: '/xyz',
        description: 'Description of content with the title of xyz.',
        title: 'xyz'
      }
    ]
  end

  it 'saves an item per entry in Search API' do
    publishing_api_get_editions(content_items, fields: fields, per_page: 700, states: ['published'])
    subject.process

    expect(Dimensions::Item.count).to eq(2)
  end

  it 'transform an entry in PublishingAPI into a Dimensions::Item' do
    publishing_api_get_editions(content_items, fields: fields, per_page: 700, states: ['published'])
    subject.process

    item = Dimensions::Item.find_by(content_id: 'xyz789')
    expect(item).to have_attributes(
      content_id: 'xyz789',
      path: '/xyz',
      latest: true
    )
  end
end
