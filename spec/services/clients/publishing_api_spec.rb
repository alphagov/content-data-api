require 'rails_helper'

RSpec.describe Clients::PublishingAPI do
  subject { Clients::PublishingAPI.new }

  it "loops through paged results from the gds publishing api" do
    subject.publishing_api = double
    page_1 = { "results" => [{}], "pages" => 2, "current_page" => 1 }
    page_2 = { "results" => [{}], "pages" => 2, "current_page" => 2 }

    expect(subject.publishing_api).to receive(:get_content_items).exactly(2).times.and_return(page_1, page_2)

    subject.find_each([]) {}
  end

  it "yields the results" do
    yielded = []
    subject.publishing_api = double
    results = { "results" => [{ some: "thing" }], "pages" => 1, "current_page" => 1 }
    allow(subject.publishing_api).to receive(:get_content_items).and_return(results)

    subject.find_each([]) { |x| yielded << x }

    expect(yielded).to eq([{ some: "thing" }])
  end

  it "queries with the passed in options" do
    subject.publishing_api = double
    expected_query = {
      document_type: 'a_document_type',
      order: 'a_order',
      q: 'a_search_term',
      fields: [:field_1, :field_2]
    }
    result = { "results" => [{}], "pages" => 1, "current_page" => 1 }

    expect(subject.publishing_api).to receive(:get_content_items).with(hash_including(expected_query)).and_return(result)

    subject.find_each([:field_1, :field_2], document_type: 'a_document_type', order: 'a_order', q: 'a_search_term') {}
  end
end
