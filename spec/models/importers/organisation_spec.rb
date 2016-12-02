require 'rails_helper'

RSpec.describe Importers::Organisation do
  let(:one_content_item_response) {
    build_search_api_response [
      {
        content_id: 'content-id-1',
        link: '/item/1/path',
        title: 'title-1',
      }
    ]
  }

  let(:two_content_items_response) {
    build_search_api_response [
      {
        content_id: 'content-id-1',
        link: '/item/1/path',
        title: 'title-1',
      },
      {
        content_id: 'content-id-2',
        link: '/item/2/path',
        title: 'title-2'
      }
    ]
  }
  let(:content_item_response) {
    double(
      body: {
        public_updated_at: "2016-11-01 11:20:45.481868000 +0000",
      }.to_json
    )
  }

  it "queries the search API with the organisation's slug" do
    expected_url = 'https://www.gov.uk/api/search.json?filter_organisations=MY-SLUG&count=99&fields=content_id,link,title&start=0'
    expected_content_url = 'https://www.gov.uk/api/content/item/1/path'

    expect(HTTParty).to receive(:get).once.with(expected_url).and_return(one_content_item_response)
    allow(HTTParty).to receive(:get).once.with(expected_content_url).and_return(content_item_response)

    Importers::Organisation.new('MY-SLUG', batch: 99).run
  end

  context 'Organisation' do
    it 'imports an organisation with the provided slug' do
      allow(HTTParty).to receive(:get).and_return(one_content_item_response)

      slug = 'hm-revenue-customs'
      Importers::Organisation.new(slug).run

      expect(Organisation.count).to eq(1)
      expect(Organisation.first.slug).to eq(slug)
    end

    it 'raises an exception with an organisation that does not exist' do
      response = double(body: { results: [] }.to_json)
      allow(HTTParty).to receive(:get).and_return(response)

      expect { Importers::Organisation.new('none-existing-org').run }.to raise_error('No result for slug')
    end
  end

  context 'Content Items' do
    before { allow(HTTParty).to receive(:get).and_return(two_content_items_response) }
    let(:organisation) { Organisation.find_by(slug: 'a-slug') }

    it 'imports all content items for the organisation' do
      Importers::Organisation.new('a-slug').run
      expect(organisation.content_items.count).to eq(2)
    end

    it 'imports only content items where content_id is present' do
      allow(HTTParty).to receive(:get).and_return(build_search_api_response([
        {
          content_id: 'content-id',
          link: '/item/1/path',
          title: 'title-1',
        },
        {
          content_id: '',
          link: '/item/2/path',
          title: 'title-2',
        }
      ]))

      Importers::Organisation.new('a-slug').run
      expect(organisation.content_items.count).to eq(1)
    end

    it 'imports a `content_id` for every content item' do
      Importers::Organisation.new('a-slug').run
      content_ids = organisation.content_items.pluck(:content_id)
      expect(content_ids).to eq(%w(content-id-1 content-id-2))
    end

    it 'imports a `link` for every content item' do
      Importers::Organisation.new('a-slug').run
      links = organisation.content_items.pluck(:link)
      expect(links).to eq(%w(/item/1/path /item/2/path))
    end

    it 'imports a `title` for every content item' do
      allow(HTTParty).to receive(:get).and_return(two_content_items_response)
      Importers::Organisation.new('a-slug').run

      organisation = Organisation.find_by(slug: 'a-slug')
      titles = organisation.content_items.pluck(:title)

      expect(titles).to eq(%w(title-1 title-2))
    end

    it 'imports a `public_updated_at` for each content item' do
      search_url = "https://www.gov.uk/api/search.json?filter_organisations=a-slug&count=10&fields=content_id,link&start=0"
      content_base_path_1 = "https://www.gov.uk/api/content/item/1/path"
      content_base_path_2 = "https://www.gov.uk/api/content/item/2/path"

      allow(HTTParty).to receive(:get).once.with(search_url).and_return(two_content_items_response)
      allow(HTTParty).to receive(:get).once.with(content_base_path_1).and_return(content_item_response)
      allow(HTTParty).to receive(:get).once.with(content_base_path_2).and_return(content_item_response)

      Importers::Organisation.new('a-slug').run
      organisation = Organisation.find_by(slug: 'a-slug')

      content_id = organisation.content_items.pluck(:content_id).first
      public_update = organisation.content_items.pluck(:public_updated_at).first

      expect(content_id).to eq('content-id-1')
      expect(public_update).to eq(Time.parse('2016-11-01 11:20:45.481868'))
    end
  end

  context 'Pagination' do
    it 'paginates through all the content items for an organisation' do
      expect(HTTParty).to receive(:get).exactly(5).times.and_return(two_content_items_response, one_content_item_response)
      Importers::Organisation.new('a-slug', batch: 2).run
      organisation = Organisation.find_by(slug: 'a-slug')

      expect(organisation.content_items.count).to eq(3)
    end

    it 'handles last page with 0 results when organisation already has content items' do
      expect(HTTParty).to receive(:get).exactly(3).times.and_return(one_content_item_response, build_search_api_response([]))
      Importers::Organisation.new('a-slug', batch: 1).run
      organisation = Organisation.find_by(slug: 'a-slug')

      expect(organisation.content_items.count).to eq(1)
    end
  end

  def build_search_api_response(payload)
    double(body: {
      results: payload
    }.to_json)
  end
end
