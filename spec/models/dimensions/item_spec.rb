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

    describe '.existing_latest_items' do
      let(:content_id_1) { 'd5348817-0c34-4942-9111-2331e12cb1c5' }
      let(:content_id_2) { 'aaaaaaaa-0c34-4942-9111-2331e12cb1c5' }
      let(:base_path_1_1) { '/foo/part1' }
      let(:base_path_1_2) { '/foo/part2' }
      let(:base_path_2) { '/bar' }

      let!(:item_1_1) do
        create(
          :dimensions_item,
          document_type: 'guide',
          base_path: base_path_1_1,
          content_id: content_id_1
        )
      end

      let!(:item_1_2) do
        create(
          :dimensions_item,
          document_type: 'guide',
          base_path: base_path_1_2,
          content_id: content_id_1
        )
      end

      let!(:item_2) do
        create(
          :dimensions_item,
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
          :dimensions_item,
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
