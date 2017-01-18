require 'rails_helper'

RSpec.feature 'rake import:content_items_by_organisation[{department-slug}]', type: :feature do
  let(:search_api_response) { { results: [{ link: '/link-1' }, { link: '/link-2' }] }.to_json }
  let(:content_item_1) { attributes_for(:content_item, base_path: '/link-1').to_json }
  let(:content_item_2) { attributes_for(:content_item, base_path: '/link-2').to_json }

  before do
    Rake::Task['import:content_items_by_organisation'].reenable

    create(:organisation, slug: 'the-organisation-slug')
  end

  subject { Rake::Task['import:content_items_by_organisation'].invoke('the-organisation-slug') }

  it 'creates all the content items belonging to an organisation' do
    stub_request(:get, %r{.*}).to_return(
      { :status => 200, :body => search_api_response },
      { :status => 200, :body => content_item_1 },
      { :status => 200, :body => content_item_2 }      
    )

    expect { subject }.to change { ContentItem.count }.by(2)
  end

  it 'saves the content item attributes' do
    content_item_1 = attributes_for(:content_item, base_path: '/link-1', title: 'new-title').to_json
    stub_request(:get, %r{.*}).to_return(
      { :status => 200, :body => search_api_response },
      { :status => 200, :body => content_item_1 }
    )

    subject

    content_item = ContentItem.find_by(base_path: '/link-1')
    expect(content_item.title).to include('new-title')
  end
end
