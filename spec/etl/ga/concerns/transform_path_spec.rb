require "rails_helper"

RSpec.describe GA::Concerns::TransformPath do
  class Dummy
    include GA::Concerns::TransformPath
    include Concerns::Traceable
  end

  it "events that have gov.uk prefix get formatted to remove prefix" do
    create(:ga_event, page_path: "/https://www.gov.uk/topics", process_name: 'views')
    events_with_prefix = Events::GA.where("page_path ~ '^\/https:\/\/www.gov.uk'")
    expect(events_with_prefix.count).to eq 1

    Dummy.new.remove_invalid_prefix

    events_with_prefix = Events::GA.where("page_path ~ '^\/https:\/\/www.gov.uk'")
    expect(events_with_prefix.count).to eq 0
  end
end
