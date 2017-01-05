require 'rails_helper'

RSpec.feature 'rake import:organisation[{department-slug}]', type: :feature do
  let(:search_api_response) { double(body: { results: [{ link: '/link-1' }, { link: '/link-2' }] }.to_json) }
  let(:content_item_1) { double(body: attributes_for(:content_item, base_path: '/link-1').to_json) }
  let(:content_item_2) { double(body: attributes_for(:content_item, base_path: '/link-2').to_json) }

  before do
    allow_any_instance_of(Services::GoogleAnalytics).to receive(:page_views).and_return(
      {
        '/item/1/path': 1,
        '/item/2/path': 2
      }.with_indifferent_access
    )

    Rake::Task['import:content_items_by_organisation'].reenable

    create(:organisation, slug: 'the-organisation-slug')
  end

  subject { Rake::Task['import:content_items_by_organisation'].invoke('the-organisation-slug') }

  it 'creates all the content items belonging to an organisation' do
    allow(HTTParty).to receive(:get).and_return(search_api_response, content_item_1, content_item_2)

    expect { subject }.to change { ContentItem.count }.by(2)
  end

  it 'saves the content item attributes' do
    content_item_1 = double(body: attributes_for(:content_item, base_path: '/link-1', title: 'new-title').to_json)
    allow(HTTParty).to receive(:get).and_return(search_api_response, content_item_1)
    subject

    content_item = ContentItem.find_by(base_path: '/link-1')
    expect(content_item.title).to include('new-title')
  end
end
