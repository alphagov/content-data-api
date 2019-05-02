RSpec.describe 'rake publishing_api:*', type: task do
  let(:num_of_consumers) { 3 }
  let(:mock_consumers) { build_mock_consumers(num_of_consumers) }

  before(:all) do
    ENV['RABBITMQ_QUEUE'] = 'content_data_api'
    ENV['RABBITMQ_QUEUE_BULK'] = 'content_data_api_govuk_importer'
  end

  it 'starts listener for PublishingAPI events' do
    expect(GovukMessageQueueConsumer::Consumer).to receive(:new).with(
      queue_name: 'content_data_api',
      processor: an_instance_of(Streams::Consumer),
    ).and_return(*mock_consumers)

    num_of_consumers.times do |i|
      expect(mock_consumers[i]).to receive(:run).with(subscribe_opts: { block: false })
    end

    Rake::Task['publishing_api:consumer'].invoke
  end

  it 'starts listener for PublishingAPI bulk preload events' do
    expect(GovukMessageQueueConsumer::Consumer).to receive(:new).with(
      queue_name: 'content_data_api_govuk_importer',
      processor: an_instance_of(Streams::Consumer),
    ).and_return(*mock_consumers)

    num_of_consumers.times do |i|
      expect(mock_consumers[i]).to receive(:run).with(subscribe_opts: { block: false })
    end

    Rake::Task['publishing_api:bulk_import_consumer'].invoke
  end
end

def build_mock_consumers(num_of_consumers)
  # sets up the mock consumers and mock channels
  # channels are stubbed to appear closed to prevent inifite looping
  (1..num_of_consumers).map do |i|
    channel = double("bunny_channel#{i}", closed?: true)
    bunny_consumer = double("bunny_consumer#{i}", channel: channel)
    double("govuk_consumer#{i}", run: bunny_consumer)
  end
end
