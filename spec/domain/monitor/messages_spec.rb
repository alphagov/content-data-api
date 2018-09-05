RSpec.describe Monitor::Messages do
  before do
    allow(GovukStatsd).to receive(:increment)
  end

  it 'increments major if routing key ends .major' do
    message = build(:message, routing_key: 'news_story.major')
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.major")
    Monitor::Messages.run(message)
  end

  it 'increments minor if routing key ends .minor' do
    message = build(:message, routing_key: 'news_story.minor')
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.minor")
    Monitor::Messages.run(message)
  end

  it 'increments links if routing key ends .links' do
    message = build(:message, routing_key: 'news_story.links')
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.links")
    Monitor::Messages.run(message)
  end

  it 'increments republish if routing key ends .republish' do
    message = build(:message, routing_key: 'news_story.republish')
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.republish")
    Monitor::Messages.run(message)
  end

  it 'increments unpublish if routing key ends .unpublish' do
    message = build(:message, routing_key: 'news_story.unpublish')
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.unpublish")
    Monitor::Messages.run(message)
  end

  it 'increments discarded if routing key ends .discarded' do
    message = build(:message, routing_key: 'news_story.discarded')
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.discarded")
    Monitor::Messages.run(message)
  end
end
