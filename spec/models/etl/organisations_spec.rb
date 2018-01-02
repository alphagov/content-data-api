require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe ETL::Organisations do
  subject { described_class }

  let(:query) do
    %r{search.json\?.*(fields=title,slug,description,link,organisation_state,content_id).*(filter_format=organisation)}
  end

  it 'extracts organisations dimension from Search API' do
    stub_request(:get, query).to_return(body: rummager_response)
    result = subject.process

    expect(Dimensions::Organisation.count).to eq(2)
    expect(Dimensions::Organisation.all).to match_array(result)
  end

  it 'transforms and load an Organisation in the Dimensions table' do
    stub_request(:get, query).to_return(body: rummager_response)
    subject.process

    organisation = Dimensions::Organisation.first
    expect(organisation).to have_attributes(
      content_id: 'c36bd301-d0c5-4492-86ad-ee7843b8383b',
      title: 'Companies House',
      slug: 'companies-house',
      description: 'The home of Companies House  on GOV.UK. We incorporate and dissolve limited companies. We register company information and make it available to the public.',
      link: '/government/organisations/companies-house',
      state: 'live',
    )
  end

  it 'raises a validation error an organisation is not valid' do
    invalid_response = %[{ "results": [{ "invalid": "response" }] }]
    stub_request(:get, query).to_return(body: invalid_response)

    expect(-> { subject.process }).to raise_error(ActiveRecord::RecordInvalid)
  end

  context 'when organisations already exist' do
    before do
      stub_request(:get, query).to_return(body: rummager_response)
      subject.process
    end

    it 'does not store duplicated organisations' do
      subject.process

      expect(Dimensions::Organisation.count).to eq(2)
    end

    it 'adds a new item if an attribute changed' do
      Dimensions::Organisation.first.update(title: 'old title')
      subject.process

      expect(Dimensions::Organisation.count).to eq(3)
    end

    it 'returns the latest version of each item' do
      Dimensions::Organisation.first.update(title: 'old title')
      result = subject.process

      expect(result.pluck(:title)).to include('Companies House', 'HM Revenue & Customs')
    end
  end

  it 'returns the list of persisted items' do
    stub_request(:get, query).to_return(body: rummager_response)
    result = subject.process

    expect(Dimensions::Organisation.all).to match_array(result)
  end

  def rummager_response
    <<-JSON
      {
         "results":[
            {
               "content_id":"c36bd301-d0c5-4492-86ad-ee7843b8383b",
               "title":"Companies House",
               "slug":"companies-house",
               "description":"The home of Companies House  on GOV.UK. We incorporate and dissolve limited companies. We register company information and make it available to the public.",
               "link":"/government/organisations/companies-house",
               "organisation_state":"live",
               "index":"government",
               "es_score":null,
               "_id":"/government/organisations/companies-house",
               "elasticsearch_type":"edition",
               "document_type":"edition"
            },
            {
               "content_id":"6667cce2-e809-4e21-ae09-cb0bdc1ddda3",
               "title":"HM Revenue & Customs",
               "slug":"hm-revenue-customs",
               "description":"The home of HM Revenue & Customs on GOV.UK. We are the UK’s tax, payments and customs authority, and we have a vital purpose: we collect the money that pays for the UK’s public services and help families and individuals with targeted financial support. We do this by being impartial and increasingly effective and efficient in our administration. We help the honest majority to get their tax right and make it hard for the dishonest minority to cheat the system.",
               "link":"/government/organisations/hm-revenue-customs",
               "organisation_state":"live",
               "index":"government",
               "es_score":null,
               "_id":"/government/organisations/hm-revenue-customs",
               "elasticsearch_type":"edition",
               "document_type":"edition"
            }
         ],
         "total":1035,
         "start":0,
         "aggregates":{
         },
         "suggested_queries":[
         ]
      }
    JSON
  end
end
