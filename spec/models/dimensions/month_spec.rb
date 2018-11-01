require 'rails_helper'

RSpec.describe Dimensions::Month, type: :model do
  it { is_expected.to validate_presence_of(:month_number) }
  it { is_expected.to validate_numericality_of(:month_number).only_integer }
  it { is_expected.to validate_inclusion_of(:month_number).in_range(1..12) }

  it { is_expected.to validate_presence_of(:month_name) }
  it { is_expected.to validate_inclusion_of(:month_name).in_array(%w(January February March April May June July August September October November December)) }

  it { is_expected.to validate_presence_of(:month_name_abbreviated) }
  it { is_expected.to validate_inclusion_of(:month_name_abbreviated).in_array(%w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)) }

  it { is_expected.to validate_presence_of(:year) }
  it { is_expected.to validate_numericality_of(:year).only_integer }

  it { is_expected.to validate_presence_of(:quarter) }
  it { is_expected.to validate_numericality_of(:quarter).only_integer }
  it { is_expected.to validate_inclusion_of(:quarter).in_range(1..4) }

  describe '.build_from_string' do
    subject { described_class }

    it 'builds a month dimension' do
      date = subject.build_from_string('2018-12')

      expect(date).to have_attributes(
        id: '2018-12',
        month_number: 12,
        month_name: 'December',
        month_name_abbreviated: 'Dec',
        quarter: 4,
        year: 2018,
      )
    end
  end

  describe '.current' do
    subject { described_class }

    it 'returns current month' do
      Timecop.freeze(2018, 10, 12) do
        current_month = Dimensions::Month.build_from_string('2018-10')

        expect(subject.current).to eq(current_month)
      end
    end
  end

  describe '.build' do
    subject { described_class }

    it 'builds a month dimension' do
      date = subject.build(Date.new(2018, 12, 1))

      expect(date).to have_attributes(
        id: '2018-12',
        month_number: 12,
        month_name: 'December',
        month_name_abbreviated: 'Dec',
        quarter: 4,
        year: 2018,
      )
    end

    it 'uses two digits to build the month' do
      date = subject.build(2018, 2)

      expect(date).to have_attributes(id: '2018-02')
    end
  end
end
