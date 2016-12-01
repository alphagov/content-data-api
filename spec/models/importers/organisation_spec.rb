require 'rails_helper'

RSpec.describe Importers::Organisation do
  let(:one_content_item_response) { build_seach_api_response [content_id: 'content-id-1'] }
  let(:two_content_items_response) { build_seach_api_response [{ content_id: 'content-id-1', link: 'content/1/path' }, { content_id: 'content-id-2', link: 'content/2/path' }] }

  it "queries the search API with the organisation's slug" do
    expected_url = 'https://www.gov.uk/api/search.json?filter_organisations=MY-SLUG&count=99&fields=content_id,link&start=0'
    expect(HTTParty).to receive(:get).with(expected_url).and_return(one_content_item_response)

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

    it 'imports a `content_id` for every content item' do
      Importers::Organisation.new('a-slug').run
      content_ids = organisation.content_items.pluck(:content_id)
      expect(content_ids).to eq(%w(content-id-1 content-id-2))
    end

    it 'imports a `link` for every content item' do
      Importers::Organisation.new('a-slug').run
      links = organisation.content_items.pluck(:link)
      expect(links).to eq(%w(content/1/path content/2/path))
    end
  end

  context 'Pagination' do
    it 'paginates through all the content items for an organisation' do
      expect(HTTParty).to receive(:get).twice.and_return(two_content_items_response, one_content_item_response)
      Importers::Organisation.new('a-slug', batch: 2).run
      organisation = Organisation.find_by(slug: 'a-slug')

      expect(organisation.content_items.count).to eq(3)
    end

    it 'handles last page with 0 results' do
      expect(HTTParty).to receive(:get).twice.and_return(one_content_item_response, build_seach_api_response([]))
      Importers::Organisation.new('a-slug', batch: 1).run
      organisation = Organisation.find_by(slug: 'a-slug')

      expect(organisation.content_items.count).to eq(1)
    end
  end

  def build_seach_api_response(payload)
    double(body: {
      results: payload
    }.to_json)
  end
end
