RSpec.describe 'rake publishing_api:*', type: task do
  let(:consumer) { double('message_consumer', run: nil) }

  it 'starts listener for PublishingAPI events' do
    expect(GovukMessageQueueConsumer::Consumer).to receive(:new).with(
      queue_name: 'content_performance_manager',
      processor: an_instance_of(PublishingAPI::Consumer),
    ).and_return(consumer)

    Rake::Task['publishing_api:consumer'].invoke
  end

  it 'starts listener for PublishingAPI bulk preload events' do
    expect(GovukMessageQueueConsumer::Consumer).to receive(:new).with(
      queue_name: 'content_performance_manager_govuk_importer',
      processor: an_instance_of(PublishingAPI::Consumer),
    ).and_return(consumer)

    Rake::Task['publishing_api:bulk_import_consumer'].invoke
  end
end
