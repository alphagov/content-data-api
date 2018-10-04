RSpec.describe Dimensions::Item, type: :model do
  let(:now) { Time.new(2018, 2, 21, 12, 31, 2) }

  it { is_expected.to validate_presence_of(:content_id) }
  it { is_expected.to validate_presence_of(:base_path) }
  it { is_expected.to validate_presence_of(:publishing_api_payload_version) }
  it { is_expected.to validate_presence_of(:schema_name) }
  it { is_expected.to validate_presence_of(:warehouse_item_id) }

  describe 'Filtering' do
    subject { Dimensions::Item }

    it '.by_base_path' do
      item1 = create(:edition, base_path: '/path1')
      create(:edition, base_path: '/path2')

      results = subject.by_base_path('/path1')
      expect(results).to match_array([item1])
    end

    it '.by_content_id' do
      item1 = create(:edition, content_id: 'id1')
      create(:edition, content_id: 'id2')

      results = subject.by_content_id('id1')
      expect(results).to match_array([item1])
    end

    it '.by_organisation_id' do
      item1 = create(:edition, organisation_id: 'org-1')
      create(:edition, organisation_id: 'org-2')

      results = subject.by_organisation_id('org-1')
      expect(results).to match_array([item1])
    end

    it '.by_locale' do
      item1 = create(:edition, locale: 'fr')
      create(:edition, locale: 'de')

      results = subject.by_locale('fr')
      expect(results).to match_array(item1)
    end

    describe '.outdated_subpages' do
      let(:content_id) { 'd5348817-0c34-4942-9111-2331e12cb1c5' }
      let(:locale) { 'fr' }

      it 'filters out the passed paths' do
        create :edition, base_path: '/path-1', locale: locale, content_id: content_id
        create :edition, base_path: '/path-1/part-1', locale: locale, content_id: content_id
        create :edition, base_path: '/path-1/part-2.fr', locale: locale, content_id: content_id
        create :edition, base_path: '/path-1/part-2', locale: 'en', content_id: content_id
        expect(Dimensions::Item.outdated_subpages(content_id, locale, ['/path-1', '/path-1/part-1']).map(&:base_path)).to eq(['/path-1/part-2.fr'])
      end
    end

    it '.by_document_type' do
      item1 = create(:edition, document_type: 'guide')
      create(:edition, document_type: 'local_transaction')

      results = subject.by_document_type('guide')
      expect(results).to match_array([item1])
    end

    it '.latest' do
      item1 = create :edition, latest: true
      _item2 = create :edition, latest: false

      expect(subject.latest).to match_array([item1])
    end

    describe '.existing_latest_items' do
      let(:content_id_1) { 'd5348817-0c34-4942-9111-2331e12cb1c5' }
      let(:content_id_2) { 'aaaaaaaa-0c34-4942-9111-2331e12cb1c5' }
      let(:base_path_1_1) { '/foo/part1' }
      let(:base_path_1_2) { '/foo/part2' }
      let(:base_path_2) { '/bar' }

      let!(:item_1_1) do
        create(
          :edition,
          document_type: 'guide',
          base_path: base_path_1_1,
          content_id: content_id_1
        )
      end

      let!(:item_1_2) do
        create(
          :edition,
          document_type: 'guide',
          base_path: base_path_1_2,
          content_id: content_id_1
        )
      end

      let!(:item_2) do
        create(
          :edition,
          document_type: 'guide',
          base_path: '/bar',
          content_id: content_id_2
        )
      end

      it "includes items with the same content id as the new thing, even if the base path has changed" do
        new_paths = ['/baz']
        existing = Dimensions::Item.existing_latest_items(content_id_2, 'en', new_paths)
        expect(existing).to eq([item_2])
      end

      it "includes items with a different content id that clash with a new base path" do
        new_content_id = 'bbbbbbbb-0c34-4942-9111-2331e12cb1c5'
        new_paths = ['/bar']
        existing = Dimensions::Item.existing_latest_items(new_content_id, 'en', new_paths)

        expect(existing).to eq([item_2])
      end

      it "excludes items with a different locale" do
        translation = create(
          :edition,
          document_type: 'guide',
          base_path: '/bar.fr',
          content_id: content_id_2,
          locale: 'fr'
        )

        existing = Dimensions::Item.existing_latest_items(content_id_2, 'en', [base_path_2])

        expect(existing).to include(item_2)
        expect(existing).not_to include(translation)
      end

      context "when the new document has one part the same and one part different" do
        let(:new_paths) { [base_path_1_1, '/foo/new-part'] }
        let(:existing) { Dimensions::Item.existing_latest_items(content_id_1, 'en', new_paths) }

        it 'includes all parts that currently map to the content id' do
          expect(existing).to include(item_1_1)
          expect(existing).to include(item_1_2)
        end

        it "doesn't include items with completely different content id and base path" do
          expect(existing).not_to include(item_2)
        end
      end
    end
  end

  describe '#promote!' do
    let(:item) { build :edition, latest: false }
    let(:warehouse_item_id) { 'warehouse-item-id' }
    let(:old_item) { build :edition, warehouse_item_id: warehouse_item_id }

    before do
      item.promote!(old_item)
    end

    it 'set the latest attribute to true' do
      expect(item.latest).to be true
    end

    it 'sets the latest attribute to false for the old version' do
      expect(old_item.latest).to be false
    end

    it 'copies the warehouse_item_id from the old item' do
      expect(item.reload.warehouse_item_id).to eq(warehouse_item_id)
    end
  end

  describe '#change_from?' do
    let(:attrs) { { base_path: '/base/path' } }
    let(:item) { create :edition, base_path: '/base/path' }

    it 'returns true if would be changed by the given attributes' do
      expect(item.change_from?(attrs.merge(base_path: '/new/base/path'))).to eq(true)
    end

    it 'returns false if would not be changed by the given attributes' do
      expect(item.change_from?(attrs)).to eq(false)
    end

    it 'ignores the raw_json attribute' do
      expect(item.change_from?(attrs.merge(raw_json: '{}'))).to eq(false)
    end
  end

  describe '#metadata' do
    let(:item) do
      create :edition,
        title: 'The Title',
        base_path: '/the/base/path',
        first_published_at: '2018-01-01',
        public_updated_at: '2018-05-20',
        publishing_app: 'publisher',
        document_type: 'guide',
        primary_organisation_title: 'The ministry'
    end

    it 'returns the correct attributes' do
      expect(item.reload.metadata).to eq(
        base_path: '/the/base/path',
        title: 'The Title',
        first_published_at: Time.new(2018, 1, 1).strftime("%Y-%m-%d"),
        public_updated_at: Time.new(2018, 5, 20).strftime("%Y-%m-%d"),
        publishing_app: 'publisher',
        document_type: 'guide',
        primary_organisation_title: 'The ministry'
      )
    end
  end
end
