require 'rails_helper'

RSpec.describe Dimensions::Item, type: :model do
  describe '.oudated' do
    subject { described_class.outdated }

    let(:item) { create(:dimensions_item) }

    it 'returns true if outdated? and latest?' do
      item.update(latest: true, outdated: true)

      expect(subject).to match_array(item)
    end

    it 'returns false if outdated? and not latest?' do
      item.update(latest: false, outdated: true)

      expect(subject).to be_empty
    end

    it 'returns false if not outdated? and latest?' do
      item.update(latest: true, outdated: false)

      expect(subject).to be_empty
    end
  end

  describe '.outdated_before' do
    let(:date) { Date.new(2018, 2, 2) }

    it 'only returns outdated items in their latest version' do
      create(:dimensions_item, latest: false, outdated: true, updated_at: Time.utc(2018, 2, 1, 23, 59, 59))

      create(:dimensions_item, outdated: true, updated_at: Time.utc(2018, 2, 2))
      expect(Dimensions::Item.outdated_before(date)).to be_empty
    end

    it 'returns the outdated items updated before the given date' do
      expected_item = create(:dimensions_item, outdated: true, updated_at: Time.utc(2018, 2, 1, 23, 59, 59))
      create(:dimensions_item, outdated: true, updated_at: Time.utc(2018, 2, 2))
      expect(Dimensions::Item.outdated_before(date)).to match_array(expected_item)
    end
  end

  describe '#outdate!' do
    let(:item) { create(:dimensions_item, outdated: false) }

    it 'sets the outdated? flag to true' do
      item.outdate!

      expect(item.reload.outdated?).to be true
    end

    it 'sets the oudated_at time' do
      time = Time.zone.now
      Timecop.freeze(time) do
        item.outdate!

        expect(item.reload.outdated_at).to eq(time)
      end
    end
  end
end
