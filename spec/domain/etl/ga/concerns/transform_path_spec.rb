RSpec.describe Etl::GA::Concerns::TransformPath do
  class Dummy
    include Etl::GA::Concerns::TransformPath
    include Traceable
  end

  it "events that have gov.uk prefix get formatted to remove prefix" do
    create(:ga_event, page_path: "/https://www.gov.uk/topics", process_name: "views")
    events_with_prefix = Events::GA.where("page_path ~ '^\/https:\/\/www.gov.uk'")
    expect(events_with_prefix.count).to eq 1

    Dummy.new.format_events_with_invalid_prefix

    events_with_prefix = Events::GA.where("page_path ~ '^\/https:\/\/www.gov.uk'")
    expect(events_with_prefix.count).to eq 0
  end

  context "when an event exists with the same page_path after formatting" do
    subject { Dummy.new }

    let!(:event2) do
      create(
        :ga_event,
        :with_views,
        page_path: "/https://www.gov.uk/topics",
        bounces: 1,
        upviews: 1,
        pviews: 1,
        useful_no: 1,
        useful_yes: 1,
        searches: 1,
        entrances: 1,
        exits: 1,
        page_time: 1,
      )
    end

    before(:each) do
      create(
        :ga_event,
        :with_views,
        page_path: "/topics",
        bounces: 1000,
        upviews: 100,
        pviews: 200,
        useful_no: 300,
        useful_yes: 400,
        searches: 500,
        entrances: 600,
        exits: 700,
        page_time: 1000,
      )
    end

    it "returns the correct number of metrics" do
      names_to_exclude = %w[id bounces date page_path updated_at created_at process_name page_time]
      event_attributes = event2.attribute_names.reject { |name| names_to_exclude.include?(name) }

      subject.format_events_with_invalid_prefix

      event_attributes.each do |metric_name|
        expect(event2.reload.send(metric_name)).to be > 1
      end
    end

    it "explicitly ignores bounces" do
      subject.format_events_with_invalid_prefix

      expect(event2.reload.bounces).to eq(1)
    end

    it "explicitly ignores page_time" do
      subject.format_events_with_invalid_prefix

      expect(event2.reload.page_time).to eq(1)
    end

    it "updates events with their combined upviews" do
      subject.format_events_with_invalid_prefix

      expect(event2.reload.upviews).to eq 101
    end

    it "updates events with their combined pviews" do
      subject.format_events_with_invalid_prefix

      expect(event2.reload.pviews).to eq 201
    end

    it "updates events with their combines useful_no" do
      subject.format_events_with_invalid_prefix

      expect(event2.reload.useful_no).to eq 301
    end

    it "updates events with their combines useful_yes" do
      subject.format_events_with_invalid_prefix

      expect(event2.reload.useful_yes).to eq 401
    end

    it "updates events with their combines searches" do
      subject.format_events_with_invalid_prefix

      expect(event2.reload.searches).to eq 501
    end

    it "updates events with their combines entrances" do
      subject.format_events_with_invalid_prefix

      expect(event2.reload.entrances).to eq 601
    end

    it "updates events with their combines exits" do
      subject.format_events_with_invalid_prefix

      expect(event2.reload.exits).to eq 701
    end

    it "deletes the duplicated event" do
      subject.format_events_with_invalid_prefix

      expect(Events::GA.count).to eq 1
    end
  end
end
