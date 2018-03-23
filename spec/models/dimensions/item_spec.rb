require 'rails_helper'

RSpec.describe Dimensions::Item, type: :model do
  it { is_expected.to validate_presence_of(:content_id) }

  describe '.outdated_before' do
    let(:date) { Date.new(2018, 2, 2) }
    it 'returns the outdated items updated before the given date' do
      expected_item = create(:dimensions_item, outdated: true, updated_at: Time.utc(2018, 2, 1, 23, 59, 59))
      create(:dimensions_item, outdated: true, updated_at: Time.utc(2018, 2, 2))
      expect(Dimensions::Item.outdated_before(date)).to match_array(expected_item)
    end
  end

  describe '#new_version' do
    it 'duplicates the old item with latest: true, outdated: false but does not save' do
      old_item = build(:dimensions_item,
        outdated: true,
        latest: true,
        raw_json: { 'the' => 'content' },
        content_id: 'c-id',
        base_path: '/the/path')
      new_version = old_item.new_version
      expect(new_version).to have_attributes(
        outdated: false,
        latest: true,
        raw_json: { 'the' => 'content' },
        content_id: 'c-id',
        base_path: '/the/path'
      )
      expect(new_version.new_record?).to eq(true)
    end
  end

  describe '#outdate!' do
    it 'sets the outdated? flag to true' do
      item = create(:dimensions_item, outdated: false)
      item.outdate!
      expect(item.reload.outdated?).to be true
    end
  end

  describe '#gone!' do
    it 'sets the status to "gone"' do
      item = create(:dimensions_item, outdated: false)
      item.gone!
      expect(item.reload.status).to eq 'gone'
    end
  end

  it 'stores/read a Hash with the item JSON' do
    item = create :dimensions_item, raw_json: { a: :b }
    item.reload

    expect(item.raw_json).to eq('a' => 'b')
  end

  describe '##create_empty' do
    let(:content_id) { 'new-item' }
    let(:base_path) { '/path/to/new-item' }
    it 'creates a new item with the correct attributes' do
      item = Dimensions::Item.create_empty content_id, base_path
      expect(item.reload).to have_attributes(
        content_id: content_id,
        base_path: base_path,
        outdated: true,
        latest: true
      )
    end
  end

  describe "#get_content" do
    it "returns nil if json is empty" do
      item = create(:dimensions_item, raw_json: {})
      expect(item.get_content).to eq(nil)
    end

    it 'returns the content when json is valid' do
      json = { 'schema_name' => 'valid' }
      item = create(:dimensions_item, raw_json: json)
      expect(Content::Parser).to receive(:extract_content).with(json).and_return('the content')
      expect(item.get_content).to eq('the content')
    end
  end
end
