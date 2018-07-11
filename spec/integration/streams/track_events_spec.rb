RSpec.describe 'Track Publishing API events' do
  include QualityMetricsHelpers

  let(:subject) { PublishingAPI::Consumer.new }
  let(:message) { build :message }

  before { stub_quality_metrics }

  it 'stores all the events' do
    expect {
      subject.process message
      subject.process message
    }.to change(PublishingApiEvent, :count).by(2)
  end

  context 'when the Item has no multiparts' do
    let(:content_id) { message.payload.fetch('content_id') }
    let(:dimension_item) { Dimensions::Item.find_by!(content_id: content_id) }
    let(:event) { PublishingApiEvent.first }

    it 'links the dimension_item to the event' do
      subject.process message

      expect(dimension_item.publishing_api_event).to eq(event)
    end

    it 'links the event to the item' do
      subject.process message

      expect(event.dimensions_items).to match_array(dimension_item)
    end
  end
end
