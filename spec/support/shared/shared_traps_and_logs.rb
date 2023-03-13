RSpec.shared_examples "traps and logs errors in process" do |object, method|
  let(:error) { StandardError.new }
  before do
    allow(GovukError).to receive(:notify)
    allow(object).to receive(method).and_raise(error)
  end

  it "traps and logs the error to Sentry" do
    expect(subject.process(date:)).to be false
    expect(GovukError).to have_received(:notify).with(error)
  end
end

RSpec.shared_examples "traps and logs errors in run" do |object, method|
  let(:error) { StandardError.new }
  before do
    allow(GovukError).to receive(:notify)
    allow(object).to receive(method).and_raise(error)
  end

  it "traps and logs the error to Sentry" do
    expect(subject.run).to be false
    expect(GovukError).to have_received(:notify).with(error)
  end
end
