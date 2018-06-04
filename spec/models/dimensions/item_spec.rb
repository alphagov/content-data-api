
RSpec.describe Dimensions::Item, type: :model do
  let(:now) { Time.new(2018, 2, 21, 12, 31, 2) }

  it { is_expected.to validate_presence_of(:content_id) }

  describe '#by_natural_key' do
    it 'returns the latest item of the correct locale' do
      content_id = 'the-one-we-want'
      expected_item = create(:dimensions_item, content_id: content_id, latest: true, locale: 'en')
      create(:dimensions_item, content_id: content_id, latest: false, locale: 'en')
      create(:dimensions_item, content_id: content_id, latest: true, locale: 'de')
      create(:dimensions_item, content_id: content_id, latest: true, locale: 'fr')
      expect(Dimensions::Item.by_natural_key(content_id: content_id, locale: 'en')).to eq(expected_item)
    end
  end

  describe '#copy_to_new_version!' do
    it 'creates a new item with latest: true, and clears this flag on the old one' do
      old_version = build(:dimensions_item,
        latest: true,
        raw_json: { 'the' => 'content' },
        content_id: 'c-id',
        base_path: '/the/path')

      new_version = old_version.copy_to_new_version!(base_path: '/the/new/path', payload_version: 2)

      expect(new_version).to have_attributes(
        latest: true,
        raw_json: nil,
        content_id: 'c-id',
        base_path: '/the/new/path'
      )

      expect(old_version).to have_attributes(
        latest: false,
        raw_json: { 'the' => 'content' },
        content_id: 'c-id',
        base_path: '/the/path'
      )
    end
  end

  describe '#quality_metrics_required?' do
    let(:item) { build(:dimensions_item, content_hash: 'existing-hash') }
    it 'returns true if content has changed and locale is en' do
      attributes = { content_hash: 'a different one', locale: 'en' }
      expect(item.quality_metrics_required?(attributes)).to eq(true)
    end

    it 'returns false if content has not changed' do
      attributes = { content_hash: 'existing-hash', locale: 'en' }
      expect(item.quality_metrics_required?(attributes)).to eq(false)
    end

    it 'returns false if content has changed and locale not en' do
      attributes = { content_hash: 'existing-hash', locale: 'de' }
      expect(item.quality_metrics_required?(attributes)).to eq(false)
    end
  end

  describe '#gone!' do
    it 'sets the status  to "gone"' do
      item = create(:dimensions_item)
      item.gone!
      expect(item.reload.status).to eq 'gone'
    end
  end

  it 'stores/read a Hash with the item JSON' do
    item = create :dimensions_item, raw_json: { a: :b }
    item.reload

    expect(item.raw_json).to eq('a' => 'b')
  end

  describe '#create_empty' do
    let(:content_id) { 'new-item' }
    let(:base_path) { '/path/to/new-item' }
    it 'creates a new item with the correct attributes' do
      item = Timecop.freeze(now) do
        Dimensions::Item.create_empty content_id: content_id, base_path: base_path, locale: 'fr', payload_version: 1
      end
      expect(item.reload).to have_attributes(
        content_id: content_id,
        base_path: base_path,
        locale: 'fr',
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
      expect(Item::Content::Parser).to receive(:extract_content).with(json).and_return('the content')
      expect(item.get_content).to eq('the content')
    end
  end
end
