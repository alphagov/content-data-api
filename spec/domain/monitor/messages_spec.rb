RSpec.describe Monitor::Messages do
  before do
    allow(GovukStatsd).to receive(:increment)
  end

  it "increments major if routing key ends .major" do
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.major")
    Monitor::Messages.run("news_story.major")
  end

  it "increments minor if routing key ends .minor" do
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.minor")
    Monitor::Messages.run("news_story.minor")
  end

  it "increments links if routing key ends .links" do
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.links")
    Monitor::Messages.run("news_story.links")
  end

  it "increments republish if routing key ends .republish" do
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.republish")
    Monitor::Messages.run("news_story.republish")
  end

  it "increments unpublish if routing key ends .unpublish" do
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.unpublish")
    Monitor::Messages.run("news_story.unpublish")
  end

  it ".increment_discarded increments discarded" do
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.discarded")
    Monitor::Messages.increment_discarded
  end
end
