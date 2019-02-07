RSpec.describe Etl::Edition::Content::ReadingTime do
  subject { described_class }

  describe '#calculate' do
    it 'calculate readability based on 200 words per minute' do
      expected_reading_time = 400 / 200

      expect(subject.calculate(400)).to eq(expected_reading_time)
    end

    it 'rounds up to 1 reading times that are between 0 and 1 minute' do
      expect(subject.calculate(20)).to eq(1)
    end
  end
end
