require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe Master::MasterProcessor do
  subject { described_class }

  let(:date) { Date.new(2018, 2, 20) }

  around do |example|
    Timecop.freeze(date) { example.run }
  end

  before do
    allow(GA::ViewsProcessor).to receive(:process)
    allow(GA::UserFeedbackProcessor).to receive(:process)
    allow(GA::InternalSearchProcessor).to receive(:process)
    allow(Feedex::Processor).to receive(:process)
    allow(Master::MetricsProcessor).to receive(:process)
  end

  describe 'runs only once per day' do
    it 'raises `DuplicateDateError` if there are already metrics for the day' do
      date = create(:dimensions_date, date: Date.yesterday)
      create(:metric, dimensions_date: date)

      expect { subject.process }.to raise_error(Master::MasterProcessor::DuplicateDateError)
    end

    it 'does not raise `DuplicateDateError` otherwise' do
      create(:dimensions_date, date: Date.yesterday)

      expect { subject.process }.to_not raise_error
    end
  end

  it 'creates a Metrics fact per content item' do
    subject.process
    expect(Master::MetricsProcessor).to have_received(:process).with(date: Date.new(2018, 2, 19))
  end

  it 'update GA metrics in the Facts table' do
    expect(GA::ViewsProcessor).to receive(:process).with(date: Date.new(2018, 2, 19))

    subject.process
  end

  it 'update Feedex metrics in the Facts table' do
    expect(Feedex::Processor).to receive(:process).with(date: Date.new(2018, 2, 19))

    subject.process
  end

  it 'can run the process for other days' do
    another_date = Date.new(2017, 12, 30)
    subject.process(date: another_date)
    expect(Master::MetricsProcessor).to have_received(:process).with(date: another_date)
    expect(GA::ViewsProcessor).to have_received(:process).with(date: another_date)
    expect(Feedex::Processor).to have_received(:process).with(date: another_date)
  end
end
