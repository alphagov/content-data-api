RSpec.describe DateRange do
  around do |example|
    Timecop.freeze Date.new(2018, 12, 25) do
      example.run
    end
  end

  describe '.valid?' do
    it 'returns false if invalid parameter' do
      expect(DateRange.valid?(:invalid_parameter)).to be_falsey
    end

    it 'returns true if valid parameters' do
      expect(DateRange.valid?('past-30-days')).to be_truthy
    end
  end

  context 'When invalid parameters' do
    it 'raises an ArgumentError' do
      expect(-> { DateRange.new(:invalid_parameter) }).to raise_error(ArgumentError)
    end
  end

  describe 'for last 30 days' do
    let(:time_period) { 'past-30-days' }

    subject { DateRange.new(time_period) }

    it { is_expected.to have_attributes(to: '2018-12-24') }
    it { is_expected.to have_attributes(from: '2018-11-25') }
    it { is_expected.to have_attributes(time_period: 'past-30-days') }
  end

  describe 'for last month' do
    let(:time_period) { 'last-month' }

    subject { DateRange.new(time_period) }

    it { is_expected.to have_attributes(to: '2018-11-30') }
    it { is_expected.to have_attributes(from: '2018-11-01') }
    it { is_expected.to have_attributes(time_period: 'last-month') }
  end

  describe 'for last 3 months' do
    let(:time_period) { 'past-3-months' }

    subject { DateRange.new(time_period) }

    it { is_expected.to have_attributes(to: '2018-12-24') }
    it { is_expected.to have_attributes(from: '2018-09-25') }
    it { is_expected.to have_attributes(time_period: 'past-3-months') }
  end

  describe 'for last 6 months' do
    let(:time_period) { 'past-6-months' }

    subject { DateRange.new(time_period) }

    it { is_expected.to have_attributes(to: '2018-12-24') }
    it { is_expected.to have_attributes(from: '2018-06-25') }
    it { is_expected.to have_attributes(time_period: 'past-6-months') }
  end

  describe 'for last year' do
    let(:time_period) { 'past-year' }

    subject { DateRange.new(time_period) }

    it { is_expected.to have_attributes(to: '2018-12-24') }
    it { is_expected.to have_attributes(from: '2017-12-25') }
    it { is_expected.to have_attributes(time_period: 'past-year') }
  end
end
