
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
