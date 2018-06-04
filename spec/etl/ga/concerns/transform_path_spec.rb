RSpec.describe GA::Concerns::TransformPath do
  class Dummy
    include GA::Concerns::TransformPath
    include Concerns::Traceable
  end

  it "events that have gov.uk prefix get formatted to remove prefix" do
    create(:ga_event, page_path: "/https://www.gov.uk/topics", process_name: 'views')
    events_with_prefix = Events::GA.where("page_path ~ '^\/https:\/\/www.gov.uk'")
    expect(events_with_prefix.count).to eq 1

    Dummy.new.format_events_with_invalid_prefix

    events_with_prefix = Events::GA.where("page_path ~ '^\/https:\/\/www.gov.uk'")
    expect(events_with_prefix.count).to eq 0
  end

  context 'when an event exists with the same page_path after formatting' do
    subject { Dummy.new }

    let!(:event2) { create(:ga_event, :with_views, page_path: "/https://www.gov.uk/topics", unique_pageviews: 1, pageviews: 1) }

    before(:each) do
      create(:ga_event, :with_views, page_path: "/topics", unique_pageviews: 100, pageviews: 200)
    end

    it 'updates events with their combined pageviews' do
      subject.format_events_with_invalid_prefix

      expect(event2.reload.pageviews).to eq 201
    end

    it 'updates events with their combined unique_pageviews' do
      subject.format_events_with_invalid_prefix

      expect(event2.reload.unique_pageviews).to eq 101
    end

    it 'deletes the duplicated event' do
      subject.format_events_with_invalid_prefix

      expect(Events::GA.count).to eq 1
    end
  end
end
