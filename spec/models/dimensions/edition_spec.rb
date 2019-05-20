RSpec.describe Dimensions::Edition, type: :model do
  let(:now) { Time.new(2018, 2, 21, 12, 31, 2) }

  it { is_expected.to validate_presence_of(:content_id) }
  it { is_expected.to validate_presence_of(:base_path) }
  it { is_expected.to validate_presence_of(:publishing_api_payload_version) }
  it { is_expected.to validate_presence_of(:schema_name) }
  it { is_expected.to validate_presence_of(:warehouse_item_id) }

  describe 'Filtering' do
    subject { Dimensions::Edition }

    it '.by_base_path' do
      edition1 = create(:edition, base_path: '/path1')
      create(:edition, base_path: '/path2')

      results = subject.by_base_path('/path1')
      expect(results).to match_array([edition1])
    end

    describe '.outdated_subpages' do
      let(:content_id) { 'd5348817-0c34-4942-9111-2331e12cb1c5' }
      let(:locale) { 'fr' }

      it 'filters out the passed paths' do
        create :edition, :multipart, base_path: '/path-1', locale: locale, content_id: content_id
        create :edition, :multipart, base_path: '/path-1/part-1', locale: locale, content_id: content_id
        create :edition, :multipart, base_path: '/path-1/part-2.fr', locale: locale, content_id: content_id
        create :edition, :multipart, base_path: '/path-1/part-2', locale: 'en', content_id: content_id
        expect(Dimensions::Edition.outdated_subpages(content_id, locale, ['/path-1', '/path-1/part-1']).map(&:base_path)).to eq(['/path-1/part-2.fr'])
      end
    end

    it '.live' do
      edition1 = create :edition, live: true
      create :edition, live: false

      expect(subject.live).to match_array([edition1])
    end
  end

  describe '.find_latest' do
    it 'return the most recent editon for a content item' do
      content_id = SecureRandom.uuid
      edition1 = create :edition, content_id: content_id, locale: 'en'
      edition2 = create :edition, content_id: content_id, locale: 'en', replaces: edition1

      warehouse_item_id = "#{content_id}:en"
      latest_edition = Dimensions::Edition.find_latest(warehouse_item_id)
      expect(latest_edition).to eq(edition2)
    end

    it 'return the most recent editon for a content item for locale' do
      content_id = SecureRandom.uuid
      edition1 = create :edition, content_id: content_id, locale: 'en'
      edition2 = create :edition, content_id: content_id, locale: 'en', replaces: edition1
      create :edition, content_id: content_id, locale: 'cy'

      warehouse_item_id = "#{content_id}:en"
      latest_edition = Dimensions::Edition.find_latest(warehouse_item_id)
      expect(latest_edition).to eq(edition2)
    end

    it 'return the most recent editon for content id' do
      content_id = SecureRandom.uuid
      edition1 = create :edition, content_id: content_id, locale: 'en'
      edition2 = create :edition, content_id: content_id, locale: 'en', replaces: edition1
      create :edition
      create :edition

      warehouse_item_id = "#{content_id}:en"
      latest_edition = Dimensions::Edition.find_latest(warehouse_item_id)
      expect(latest_edition).to eq(edition2)
    end

    it 'return nil for no edition for locale' do
      create :edition, locale: 'cy'
      content_id = SecureRandom.uuid

      warehouse_item_id = "#{content_id}:en"
      latest_edition = Dimensions::Edition.find_latest(warehouse_item_id)
      expect(latest_edition).to eq(nil)
    end

    it 'return nil for no edition for content_id' do
      create :edition
      other_content_id = SecureRandom.uuid

      warehouse_item_id = "#{other_content_id}:en"
      latest_edition = Dimensions::Edition.find_latest(warehouse_item_id)
      expect(latest_edition).to eq(nil)
    end
  end

  describe '#promote!' do
    context 'for published edition' do
      let(:edition) { build :edition, live: false }
      let(:warehouse_item_id) { 'warehouse-item-id' }
      let(:old_edition) { build :edition, warehouse_item_id: warehouse_item_id }

      before do
        edition.promote!(old_edition)
      end

      it 'set the live attribute to true' do
        expect(edition.live).to be true
      end

      it 'sets the live attribute to false for the old version' do
        expect(old_edition.live).to be false
      end
    end

    context 'for unpublished edition' do
      let(:edition) { build :edition, live: false, document_type: 'gone' }
      let(:warehouse_item_id) { 'warehouse-item-id' }
      let(:old_edition) { build :edition, warehouse_item_id: warehouse_item_id }

      before do
        edition.promote!(old_edition)
      end

      it 'set the live attribute to true' do
        expect(edition.live).to be false
      end

      it 'sets the live attribute to false for the old version' do
        expect(old_edition.live).to be false
      end
    end
  end

  describe '#change_from?' do
    let(:attrs) { { base_path: '/base/path' } }
    let(:edition) { create :edition, base_path: '/base/path' }

    it 'returns true if would be changed by the given attributes' do
      expect(edition.change_from?(attrs.merge(base_path: '/new/base/path'))).to eq(true)
    end

    it 'returns false if would not be changed by the given attributes' do
      expect(edition.change_from?(attrs)).to eq(false)
    end
  end

  describe '#metadata' do
    let(:edition) do
      create :edition,
             title: 'The Title',
             base_path: '/the/base/path',
             content_id: 'the-content-id',
             locale: 'en',
             first_published_at: '2018-01-01',
             public_updated_at: '2018-05-20',
             publishing_app: 'publisher',
             document_type: 'guide',
             primary_organisation_title: 'The ministry',
             withdrawn: false,
             historical: false
    end

    it 'returns the correct attributes' do
      expect(edition.reload.metadata).to eq(
        base_path: '/the/base/path',
        content_id: 'the-content-id',
        locale: 'en',
        title: 'The Title',
        first_published_at: Time.new(2018, 1, 1).strftime("%Y-%m-%d"),
        public_updated_at: Time.new(2018, 5, 20).strftime("%Y-%m-%d"),
        publishing_app: 'publisher',
        document_type: 'guide',
        primary_organisation_title: 'The ministry',
        withdrawn: false,
        historical: false,
        parent_content_id: ''
      )
    end
  end

  describe '#parent_content_id' do
    it 'returns content_id of parent manual for a manual_section' do
      create :edition, content_id: 'the-parent', base_path: '/prefix-path/the-parent-path', document_type: 'manual'
      child = create :edition, base_path: '/prefix-path/the-parent-path/child-path', document_type: 'manual_section'

      expect(child.parent_content_id).to eq('the-parent')
    end
  end

  describe 'Unique constraint on `warehouse_item_id` and `live`' do
    it 'prevent duplicating `warehouse_item_id` for live items' do
      create :edition, warehouse_item_id: 'value', live: true

      expect(-> { create :edition, warehouse_item_id: 'value', live: true }).to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'does not prevent duplicating `warehouse_item_id` for old items' do
      create :edition, warehouse_item_id: 'value', live: true

      expect(-> { create :edition, warehouse_item_id: 'value', live: false }).to_not raise_error
    end
  end

  describe 'Unique constraint on `base_path` and `live`' do
    it 'prevent duplicating `base_path` for live items' do
      create :edition, base_path: 'value', live: true

      expect(-> { create :edition, base_path: 'value', live: true }).to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'does not prevent duplicating `base_path` for old items' do
      create :edition, base_path: 'value', live: true

      expect(-> { create :edition, base_path: 'value', live: false }).to_not raise_error
    end
  end
end
