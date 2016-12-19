require 'rails_helper'

RSpec.describe Importers::Organisation do
  let(:search_api_url_pattern) { /^https:\/\/www.gov.uk\/api\/search\.json\?.*$/ }
  let(:content_items_api_url_pattern) { /^https:\/\/www.gov.uk\/api\/content\/.*$/ }

  let(:one_content_item_response) {
    build_search_api_response [
      {
        content_id: 'content-id-1',
        link: '/item/1/path',
        title: 'title-1',
        organisations: [],
      }
    ]
  }

  let(:two_content_items_response) {
    build_search_api_response [
      {
        content_id: 'content-id-1',
        link: '/item/1/path',
        title: 'title-1',
        organisations: [],
      },
      {
        content_id: 'content-id-2',
        link: '/item/2/path',
        title: 'title-2',
        organisations: [],
      }
    ]
  }
  let(:content_item_response) {
    double(
      body: {
        public_updated_at: "2016-11-01 11:20:45.481868000 +0000",
        document_type: "guidance",
      }.to_json
    )
  }

  describe 'making API calls with HTTParty' do
    it 'queries the search API with the organisation\'s slug' do
      expected_url = 'https://www.gov.uk/api/search.json?filter_organisations=MY-SLUG&count=99&fields=content_id,link,title,organisations&start=0'
      allow(HTTParty).to receive(:get).with(content_items_api_url_pattern).and_return(content_item_response)
      expect(HTTParty).to receive(:get).once.with(expected_url).and_return(two_content_items_response)

      Importers::Organisation.new('MY-SLUG', batch: 99).run
    end

    it 'queries the content item API with base path' do
      content_api_url_with_base_path_1 = 'https://www.gov.uk/api/content/item/1/path'
      content_api_url_with_base_path_2 = 'https://www.gov.uk/api/content/item/2/path'

      allow(HTTParty).to receive(:get).once.with(search_api_url_pattern).and_return(two_content_items_response)

      expect(HTTParty).to receive(:get).once.with(content_api_url_with_base_path_1).and_return(content_item_response)
      expect(HTTParty).to receive(:get).once.with(content_api_url_with_base_path_2).and_return(content_item_response)

      Importers::Organisation.new('MY-SLUG', batch: 99).run
    end
  end

  context 'Organisation' do
    it 'imports an organisation with the provided slug' do
      allow(HTTParty).to receive(:get).with(search_api_url_pattern).and_return(one_content_item_response)
      allow(HTTParty).to receive(:get).with(content_items_api_url_pattern).and_return(content_item_response)

      slug = 'hm-revenue-customs'
      expect { Importers::Organisation.new(slug).run }.to change { Organisation.count }.by(1)
      expect(Organisation.first.slug).to eq(slug)
    end

    it 'raises an exception with an organisation that does not exist' do
      response = double(body: { results: [] }.to_json)
      allow(HTTParty).to receive(:get).once.with(search_api_url_pattern).and_return(response)

      expect { Importers::Organisation.new('none-existing-org').run }.to raise_error('No result for slug')
    end

    it 'imports the organisation title' do
      allow(HTTParty).to receive(:get).and_return(build_search_api_response([
        {
          content_id: 'content-id',
          link: '/item/1/path',
          title: 'title-1',
          organisations: [{
            title: 'An organisation title',
            slug: 'a-slug'
          }]
        }
      ]))

      Importers::Organisation.new('a-slug').run
      organisation = Organisation.find_by(slug: 'a-slug')
      expect(organisation.title).to eq('An organisation title')
    end

    it 'only imports the organisation title once' do
      allow(HTTParty).to receive(:get).and_return(build_search_api_response([
        {
          content_id: 'content-id-1',
          link: '/item/1/path',
          title: 'title-1',
          organisations: [{
            title: 'An organisation title',
            slug: 'a-slug'
          }]
        },
        {
          content_id: 'content-id-2',
          link: '/item/2/path',
          title: 'title-2',
          organisations: [{
            title: 'An organisation title',
            slug: 'a-slug'
          }]
        }.with_indifferent_access
      ]))
      expect_any_instance_of(Importers::Organisation).to receive(:add_organisation_title).once

      Importers::Organisation.new('a-slug').run
    end
  end

  describe 'Content Items' do
    before { allow(HTTParty).to receive(:get).with(content_items_api_url_pattern).and_return(content_item_response) }

    it 'imports all content items for the organisation' do
      allow(HTTParty).to receive(:get).with(search_api_url_pattern).and_return(two_content_items_response)

      Importers::Organisation.new('a-slug').run
      organisation = Organisation.find_by(slug: 'a-slug')
      expect(organisation.content_items.count).to eq(2)
    end

    it 'imports only content items where content_id is present' do
      allow(HTTParty).to receive(:get).and_return(build_search_api_response([
        {
          content_id: 'content-id',
          link: '/item/1/path',
          title: 'title-1',
          organisations: [],
        },
        {
          content_id: '',
          link: '/item/2/path',
          title: 'title-2',
          organisations: [],
        }
      ]))

      Importers::Organisation.new('a-slug').run
      organisation = Organisation.find_by(slug: 'a-slug')
      expect(organisation.content_items.count).to eq(1)
    end

    describe 'Fields ' do
      before { allow(HTTParty).to receive(:get).with(search_api_url_pattern).and_return(one_content_item_response) }

      it 'imports a `content_id` for every content item' do
        Importers::Organisation.new('a-slug').run
        organisation = Organisation.find_by(slug: 'a-slug')

        content_ids = organisation.content_items.pluck(:content_id)
        expect(content_ids).to eq(%w(content-id-1))
      end

      it 'imports a `link` for every content item' do
        Importers::Organisation.new('a-slug').run
        organisation = Organisation.find_by(slug: 'a-slug')
        links = organisation.content_items.pluck(:link)
        expect(links).to eq(%w(/item/1/path))
      end

      it 'imports a `title` for every content item' do
        Importers::Organisation.new('a-slug').run

        organisation = Organisation.find_by(slug: 'a-slug')
        titles = organisation.content_items.pluck(:title)

        expect(titles).to eq(%w(title-1))
      end

      it 'imports a `public_updated_at` for each content item' do
        Importers::Organisation.new('a-slug').run
        organisation = Organisation.find_by(slug: 'a-slug')

        content_item = organisation.content_items.first

        expect(content_item.content_id).to eq('content-id-1')
        expect(content_item.public_updated_at).to eq(Time.parse('2016-11-01 11:20:45.481868'))
      end

      it 'imports a `document_type` for every content item' do
        Importers::Organisation.new('a-slug').run
        content_items = Organisation.find_by(slug: 'a-slug').content_items
        document_type = content_items.pluck(:document_type).first

        expect(document_type).to eq('guidance')
      end
    end
  end

  context 'Pagination' do
    before { allow(HTTParty).to receive(:get).with(content_items_api_url_pattern).and_return(content_item_response) }

    it 'paginates through all the content items for an organisation' do
      expect(HTTParty).to receive(:get).twice.with(search_api_url_pattern).and_return(two_content_items_response, one_content_item_response)

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
