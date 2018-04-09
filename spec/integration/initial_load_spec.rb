require 'gds_api/test_helpers/content_store'
require 'sidekiq/testing'


RSpec.describe 'Initial load from publishing api' do
  include GdsApi::TestHelpers::PublishingApiV2
  include GdsApi::TestHelpers::ContentStore

  around do |example|
    Sidekiq::Testing.inline! do
      example.run
    end
  end


  let(:editions) do
    [
      { content_id: 'cont-1', base_path: '/one', locale: 'en' },
      { content_id: 'cont-1', base_path: '/one.de', locale: 'de' },
      { content_id: 'cont-3', base_path: '/two', locale: 'en' },
    ]
  end

  before :each do
    publishing_api_get_editions(editions, fields: %i[base_path content_id locale], per_page: 50, states: ['published'])
  end

  it 'something' do
    stub_content_item_for_path('/one', 'cont-1', 'new title')
    stub_content_item_for_path('/one.de', 'cont-1', 'new title.de')
    stub_content_item_for_path('/two', 'cont-3', 'new title 2')


    ETL::PreloadItems.process

    expect(Dimensions::Item.where(content_id: 'cont-1').count).to eq(2)
    expect(Dimensions::Item.where(locale: 'en').count).to eq(2)

    expect(Dimensions::Item.pluck(:title)).to match_array(['new title', 'new title.de', 'new title 2'])
  end

  def stub_content_item_for_path(base_path, content_id, new_title)
    content_store_has_item(base_path, content_item_for_base_path(base_path).tap { |response|
      response.merge!(
        'content_id' => content_id,
        'schema_name' => 'news_article',
        'title' => new_title,
        'details' => {
          'body' => 'some content',
        }
      )
    }, {})
  end
end
