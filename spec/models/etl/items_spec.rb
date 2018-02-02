require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe ETL::Items do
  subject { described_class }

  let(:query) do
    %r{search.json\?.*(fields=content_id,title,link,description,organisations)}
  end

  it 'saves an item per entry in Search API' do
    stub_request(:get, query).to_return(body: rummager_response)
    subject.process

    expect(Dimensions::Item.count).to eq(2)
  end

  it 'transform an entry in SearchAPI into a Dimension::Item' do
    stub_request(:get, query).to_return(body: rummager_response)
    subject.process

    item = Dimensions::Item.find_by(content_id: 'fa748fae-3de4-4266-ae85-0797ada3f40c')
    expect(item).to have_attributes(
      content_id: 'fa748fae-3de4-4266-ae85-0797ada3f40c'
    )
  end

  def rummager_response
    <<-JSON
    {
      "results": [
        {
          "content_id": "fa748fae-3de4-4266-ae85-0797ada3f40c",
          "title": "Tax your vehicle",
          "link": "/vehicle-tax",
          "description": "Renew or tax your vehicle for the first time using a reminder letter, your log book, the 'new keeper's details' section of a log book - and how to tax if you don't have any documents",
          "organisations": [
            {
              "content_id": "70580624-93b5-4aed-823b-76042486c769",
              "acronym": "DVLA",
              "link": "/government/organisations/driver-and-vehicle-licensing-agency",
              "slug": "driver-and-vehicle-licensing-agency",
              "organisation_type": "executive_agency",
              "organisation_state": "live"
            }
          ],
          "indexable_content": "Some content"
        },
        {
          "content_id": "c36bd301-d0c5-4492-86ad-ee7843b8383b",
          "title": "Companies House",
          "link": "/government/organisations/companies-house",
          "description": "The home of Companies House  on GOV.UK. We incorporate and dissolve limited companies. We register company information and make it available to the public.",
          "organisations": [
            {
              "title": "Companies House ",
              "content_id": "c36bd301-d0c5-4492-86ad-ee7843b8383b",
              "acronym": "Companies House",
              "link": "/government/organisations/companies-house",
              "slug": "companies-house",
              "organisation_type": "executive_agency",
              "organisation_state": "live"
            }
          ],
          "indexable_content": "another content"
        }
      ]
    }
    JSON
  end
end
