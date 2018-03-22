require 'gds_api/test_helpers/content_store'

RSpec.describe 'Initial load from publishing api' do
  include GdsApi::TestHelpers::PublishingApiV2

  let(:editions) do
    [
      { content_id: 'cont-1', base_path: '/one', locale: 'en' },
      { content_id: 'cont-1', base_path: '/one.de', locale: 'de' },
      { content_id: 'cont-3', base_path: '/two', locale: 'en' },
    ]
  end

  before :each do
    publishing_api_get_editions(editions, fields: %i[base_path content_id locale], per_page: 350, states: ['published'])
  end

  it 'something' do
    ETL::PreloadItems.process

    expect(Dimensions::Item.where(content_id: 'cont-1').count).to eq(2)
    expect(Dimensions::Item.where(locale: 'en').count).to eq(2)
  end
end
