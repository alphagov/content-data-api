RSpec.describe Dimensions::Item, type: :model do
  let(:now) { Time.new(2018, 2, 21, 12, 31, 2) }

  it { is_expected.to validate_presence_of(:content_id) }
  it { is_expected.to validate_presence_of(:base_path) }
  it { is_expected.to validate_presence_of(:publishing_api_payload_version) }
  it { is_expected.to validate_presence_of(:schema_name) }

  describe 'Filtering' do
    subject { Dimensions::Item }

    it '.by_base_path' do
      item1 = create(:dimensions_item, base_path: '/path1')
      create(:dimensions_item, base_path: '/path2')

      results = subject.by_base_path('/path1')
      expect(results).to match_array([item1])
    end

    it '.by_content_id' do
      item1 = create(:dimensions_item, content_id: 'id1')
      create(:dimensions_item, content_id: 'id2')

      results = subject.by_content_id('id1')
      expect(results).to match_array([item1])
    end

    it '.by_organisation_id' do
      item1 = create(:dimensions_item, primary_organisation_content_id: 'org-1')
      create(:dimensions_item, primary_organisation_content_id: 'org-2')

      results = subject.by_organisation_id('org-1')
      expect(results).to match_array([item1])
    end

    it '.by_locale' do
      item1 = create(:dimensions_item, locale: 'fr')
      create(:dimensions_item, locale: 'de')

      results = subject.by_locale('fr')
      expect(results).to match_array(item1)
    end

    it '.by_document_type' do
      item1 = create(:dimensions_item, document_type: 'guide')
      create(:dimensions_item, document_type: 'local_transaction')

      results = subject.by_document_type('guide')
      expect(results).to match_array([item1])
    end
  end

  describe '#older_than?' do
    let(:dimension_item) { build :dimensions_item, publishing_api_payload_version: 10 }

    it 'returns true when compared with `nil`' do
      other = nil

      expect(dimension_item.older_than?(other)).to be true
    end

    it 'returns true if the payload version is bigger' do
      other = build :dimensions_item, publishing_api_payload_version: 9

      expect(dimension_item.older_than?(other)).to be true
    end

    it 'returns false if the payload version is smaller' do
      other = build :dimensions_item, publishing_api_payload_version: 11

      expect(dimension_item.older_than?(other)).to be false
    end
  end

  it 'stores/read a Hash with the item JSON' do
    item = create :dimensions_item, raw_json: { a: :b }
    item.reload

    expect(item.raw_json).to eq('a' => 'b')
  end

  describe '#get_content' do
    it 'returns nil if json is empty' do
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

  describe '#promote!' do
    let(:item) { build :dimensions_item, latest: false }

    it 'set the latest attribute to true' do
      item.promote!(build(:dimensions_item))

      expect(item.latest).to be true
    end

    it 'set the latest attribute to false for the old version' do
      old_item = build :dimensions_item
      item.promote!(old_item)

      expect(old_item.latest).to be false
    end
  end
end
