require 'rails_helper'

RSpec.describe Concerns::Outdateable, type: :model do
  subject { Dimensions::Item }

  describe '.oudated' do
    let(:item) { create(:dimensions_item) }

    it 'returns true if outdated? and latest?' do
      item.update(latest: true, outdated: true)

      expect(subject.outdated).to match_array(item)
    end

    it 'returns false if outdated? and not latest?' do
      item.update(latest: false, outdated: true)

      expect(subject.outdated).to be_empty
    end

    it 'returns false if not outdated? and latest?' do
      item.update(latest: true, outdated: false)

      expect(subject.outdated).to be_empty
    end
  end

  describe '.outdated_before' do
    let(:date) { Date.new(2018, 2, 2) }
    let(:before_date) { Time.utc(2018, 2, 1, 23, 59, 59) }

    let!(:outdated_item_1) { create(:dimensions_item, outdated: true, outdated_at: before_date) }
    let!(:outdated_item_2) { create(:dimensions_item, outdated: true, outdated_at: date) }

    it 'only returns outdated items in their latest version' do
      outdated_item_1.update latest: false
      outdated_item_2.update latest: true

      expect(Dimensions::Item.outdated_before(date)).to be_empty
    end

    it 'returns the outdated items updated before the given date' do
      outdated_item_1.update latest: true
      outdated_item_2.update latest: true

      expect(Dimensions::Item.outdated_before(date)).to match_array(outdated_item_1)
    end
  end

  describe '#outdate!' do
    let(:new_base_path) { '/new/base/path' }
    let(:item) { create(:dimensions_item, outdated: false) }

    it 'sets the outdated? flag to true' do
      item.outdate!

      expect(item.reload.outdated?).to be true
    end

    it 'sets the oudated_at time' do
      Timecop.freeze(Time.new(2018, 3, 3)) { item.outdate! }
      
      expect(item.reload.outdated_at).to eq(Time.new(2018, 3, 3))
    end
  end
end
