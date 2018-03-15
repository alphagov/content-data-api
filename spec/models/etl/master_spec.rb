require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe ETL::Master do
  subject { described_class }

  let(:date) { Date.new(2018, 2, 20) }

  around do |example|
    Timecop.freeze(date) { example.run }
  end

  before do
    allow(ETL::GA).to receive(:process)
    allow(ETL::Feedex).to receive(:process)
    allow(ETL::OutdatedItems).to receive(:process)
    allow(ETL::Metrics).to receive(:process)
  end


  it 'creates a Metrics fact per content item' do
    subject.process
    expect(ETL::Metrics).to have_received(:process).with(date: Date.new(2018, 2, 19))
  end

  it 'updates the outdated items' do
    subject.process

    expect(ETL::OutdatedItems).to have_received(:process).with(date: Date.new(2018, 2, 19))
  end

  it 'update GA metrics in the Facts table' do
    expect(ETL::GA).to receive(:process).with(date: Date.new(2018, 2, 19))

    subject.process
  end

  it 'update Feedex metrics in the Facts table' do
    expect(ETL::Feedex).to receive(:process).with(date: Date.new(2018, 2, 19))

    subject.process
  end

  it 'can run the process for other days' do
    another_date = Date.new(2017, 12, 30)
    subject.process(date: another_date)
    expect(ETL::Metrics).to have_received(:process).with(date: another_date)
    expect(ETL::OutdatedItems).to have_received(:process).with(date: another_date)
    expect(ETL::GA).to have_received(:process).with(date: another_date)
    expect(ETL::Feedex).to have_received(:process).with(date: another_date)
  end
end
