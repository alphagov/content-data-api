require 'rails_helper'

RSpec.feature "Import all the content items for an organisation", type: :feature do
  let!(:organisation) { create(:organisation, slug: 'a_slug') }

  let(:two_content_items_for_an_organisation) {
    double(body: {
      results: [
        {
          link: '/link-1',
        },
        {
          link: '/link-2',
        }
      ]
    }.to_json)
  }

  let(:content_item_1) { double(body: attributes_for(:content_item, link: '/link-1').to_json) }
  let(:content_item_2) { double(body: attributes_for(:content_item, link: '/link-2').to_json) }

  before do
    Rake::Task['import:content_items_by_organisation'].reenable

    allow(HTTParty).to receive(:get).with(/https:\/\/www.gov.uk\/api\/search/).and_return(two_content_items_for_an_organisation)
    allow(HTTParty).to receive(:get).with('https://www.gov.uk/api/content/link-1').and_return(content_item_1)
    allow(HTTParty).to receive(:get).with('https://www.gov.uk/api/content/link-2').and_return(content_item_2)
  end

  it 'creates two organisations' do
    expect { Rake::Task['import:content_items_by_organisation'].invoke('a_slug') }.to change { ContentItem.count }.by(2)
  end

  it 'updates the attributes' do
    Rake::Task['import:content_items_by_organisation'].invoke('a_slug')

    content_item = ContentItem.first
    expected_attributes = JSON.parse(content_item_1.body)
    expect(content_item.title).to include(expected_attributes['title'])
    expect(content_item.link).to include(expected_attributes['link'])
  end
end
