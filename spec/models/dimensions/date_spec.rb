RSpec.describe Dimensions::Date, type: :model do
  let(:date) { ::Date.new(2017, 12, 21) }
  it { is_expected.to validate_presence_of(:date) }

  it { is_expected.to validate_presence_of(:date_name) }
  it { is_expected.to validate_presence_of(:date_name_abbreviated) }

  it { is_expected.to validate_presence_of(:year) }
  it { is_expected.to validate_numericality_of(:year).only_integer }

  it { is_expected.to validate_presence_of(:quarter) }
  it { is_expected.to validate_numericality_of(:quarter).only_integer }
  it { is_expected.to validate_inclusion_of(:quarter).in_range(1..4) }

  it { is_expected.to validate_presence_of(:month) }
  it { is_expected.to validate_numericality_of(:month).only_integer }
  it { is_expected.to validate_inclusion_of(:month).in_range(1..12) }

  it { is_expected.to validate_presence_of(:month_name) }
  it do
    is_expected.to validate_inclusion_of(:month_name)
      .in_array(
        %w(
                        January February March April May June July August
                        September October November December
                       ),
      )
  end

  it { is_expected.to validate_presence_of(:month_name_abbreviated) }
  it do
    is_expected.to validate_inclusion_of(:month_name_abbreviated)
      .in_array(
        %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec),
      )
  end

  it { is_expected.to validate_presence_of(:week) }
  it { is_expected.to validate_numericality_of(:week).only_integer }
  it { is_expected.to validate_inclusion_of(:week).in_range(1..53) }

  it { is_expected.to validate_presence_of(:day_of_year) }
  it { is_expected.to validate_numericality_of(:day_of_year).only_integer }
  it { is_expected.to validate_inclusion_of(:day_of_year).in_range(1..365) }

  it { is_expected.to validate_presence_of(:day_of_quarter) }
  it { is_expected.to validate_numericality_of(:day_of_quarter).only_integer }
  it { is_expected.to validate_inclusion_of(:day_of_quarter).in_range(1..124) }

  it { is_expected.to validate_presence_of(:day_of_month) }
  it { is_expected.to validate_numericality_of(:day_of_month).only_integer }
  it { is_expected.to validate_inclusion_of(:day_of_month).in_range(1..31) }

  it { is_expected.to validate_presence_of(:day_of_week) }
  it { is_expected.to validate_numericality_of(:day_of_week).only_integer }
  it { is_expected.to validate_inclusion_of(:day_of_week).in_range(1..7) }

  it { is_expected.to validate_presence_of(:day_name) }
  it do
    is_expected.to validate_inclusion_of(:day_name)
      .in_array(
        %w(
                        Monday Tuesday Wednesday Thursday Friday
                        Saturday Sunday
                       ),
      )
  end

  it { is_expected.to validate_presence_of(:day_name_abbreviated) }
  it do
    is_expected.to validate_inclusion_of(:day_name_abbreviated)
      .in_array(%w(Mon Tue Wed Thu Fri Sat Sun))
  end

  it { is_expected.to validate_presence_of(:weekday_weekend) }
  it do
    is_expected.to validate_inclusion_of(:weekday_weekend)
      .in_array(%w(Weekday Weekend))
  end

  describe ".build" do
    subject { described_class.build(date) }

    it "builds a date dimension from the date" do
      is_expected.to have_attributes(
        date: ::Date.new(2017, 12, 21),
        date_name: "21 December 2017",
        date_name_abbreviated: "21 Dec 2017",
        day_name: "Thursday",
        day_name_abbreviated: "Thu",
        day_of_month: 21,
        day_of_quarter: 82,
        day_of_week: 4,
        day_of_year: 355,
        month: 12,
        month_name: "December",
        month_name_abbreviated: "Dec",
        quarter: 4,
        week: 51,
        weekday_weekend: "Weekday",
        year: 2017,
      )
    end
  end

  describe ".create_with" do
    it "builds and saves a new date dimension" do
      dimensions_date = Dimensions::Date.create_with(date)
      expect(Dimensions::Date.count).to eq(1)
      expect(Dimensions::Date.first).to eq(dimensions_date)
    end
  end

  describe ".find_existing_or_create" do
    let(:date) { ::Date.new(2017, 12, 21) }

    context "when a dimension exists for the given date" do
      it "should return the existing dimension" do
        dimensions_date = create(:dimensions_date, date: date)
        dimensions_date.save!

        expect(Dimensions::Date.find_existing_or_create(date)).to eq(dimensions_date)
      end
    end

    context "when a dimension does not exist for the given date" do
      it "should return the newly created dimension" do
        dimensions_date = Dimensions::Date.find_existing_or_create(date)

        expect(Dimensions::Date.count).to eq(1)
        expect(dimensions_date.date).to eq(date)
      end
    end

    context "when a dimension created under losing race conditions" do
      it "should return the existing dimension" do
        dimensions_date = Dimensions::Date.build(date)
        allow(Dimensions::Date).to receive(:create) {
          dimensions_date.save
          raise ActiveRecord::RecordNotUnique
        }
        expect(Dimensions::Date.find_existing_or_create(date)).to eq(dimensions_date)
      end
    end
  end

  describe ".exists?" do
    context "when a dimension exists for the the given date" do
      it "returns true" do
        create(:dimensions_date, date: date)
        expect(Dimensions::Date.exists?(date)).to eq true
      end
    end
    context "when a dimension does not exist for the the given date" do
      it "returns false" do
        expect(Dimensions::Date.exists?(date)).to eq false
      end
    end
  end

  describe "Filtering" do
    subject { Dimensions::Date }

    it ".between" do
      date1 = create(:dimensions_date, date: Date.new(2018, 1, 12))
      date2 = create(:dimensions_date, date: Date.new(2018, 1, 13))
      date3 = create(:dimensions_date, date: Date.new(2018, 1, 14))
      create(:dimensions_date, date: Date.new(2018, 1, 15))

      results = subject.between(date1, date3)
      expect(results).to match_array([date1, date2, date3])
    end
  end
end
