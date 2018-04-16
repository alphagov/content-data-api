require 'rails_helper'

RSpec.describe Concerns::Outdateable, type: :model do
  subject { Dimensions::Item }

  describe '.oudated' do
    let(:item) { create(:dimensions_item) }

    it 'returns true if outdated?' do
      item.update(outdated: true)

      expect(subject.outdated).to match_array(item)
    end

    it 'returns false if not outdated?' do
      item.update(outdated: false)

      expect(subject.outdated).to be_empty
    end
  end

  describe '#outdate!' do
    let(:new_base_path) { '/new/base/path' }
    let(:item) { create(:dimensions_item, outdated: false) }

    it 'sets the outdated? flag to true' do
      item.outdate!

      expect(item.reload.outdated?).to be true
    end

    it 'sets the outdated_at time' do
      Timecop.freeze(Time.new(2018, 3, 3)) { item.outdate! }

      expect(item.reload.outdated_at).to eq(Time.new(2018, 3, 3))
    end
  end
end
