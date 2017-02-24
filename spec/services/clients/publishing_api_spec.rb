require 'rails_helper'

RSpec.describe Clients::PublishingAPI do
  subject { Clients::PublishingAPI.new }

  it "loops through paged results from the gds publishing api" do
    subject.publishing_api = double
    page_1 = { "results" => [], "pages" => 2, "current_page" => 1 }
    page_2 = { "results" => [], "pages" => 2, "current_page" => 2 }

    expect(subject.publishing_api).to receive(:get_content_items).exactly(2).times.and_return(page_1, page_2)

    subject.find_each([]) {}
  end

  it "yields the taxon fields that were requested" do
    yielded = []
    subject.publishing_api = double
    results = { "results" => ["content_id" => "an_id", "another" => "field"], "pages" => 1, "current_page" => 1 }
    allow(subject.publishing_api).to receive(:get_content_items).and_return(results)

    subject.find_each(%i(content_id)) { |x| yielded << x }

    expect(yielded).to eq([{ content_id: "an_id" }])
  end
end
