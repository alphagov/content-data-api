RSpec.describe Items::Importers::ContentDetails do
  let(:content_id) { 'content_id' }

  context 'Import contents' do
    subject { Items::Importers::ContentDetails.new(latest_dimension_item.id) }

    let(:locale) { 'en' }

    let!(:existing_content_hash) { 'ContentHashContentHash' }
    let!(:parsed_content_hash) { 'NewContentHash' }
    let!(:latest_dimension_item_fr) do
      create(:dimensions_item,
        content_id: content_id, base_path: 'fr/base_path', locale: 'fr',
        raw_json: nil, content_hash: existing_content_hash,
        publishing_api_payload_version: 1)
    end
    let!(:latest_dimension_item) do
      create(:dimensions_item,
        content_id: content_id, base_path: 'en/base_path', locale: 'en',
        raw_json: nil, content_hash: existing_content_hash,
        publishing_api_payload_version: 1)
    end
    let!(:older_dimension_item) { create(:dimensions_item, content_id: content_id, base_path: 'en/base_path', latest: false, raw_json: nil) }
    let(:raw_json) { { 'details' => 'the-json' } }

    before do
      allow(subject.content_store_client).to receive(:fetch_raw_json).and_return(raw_json)
      allow(Items::Jobs::ImportQualityMetricsJob).to receive(:perform_async)
      allow(Item::Metadata::Parser).to receive(:parse).and_return(
        raw_json: raw_json,
        number_of_pdfs: 99,
        number_of_word_files: 94,
        content_id: '09hjasdfoj234',
        locale: locale,
        title: 'A guide to coding',
        document_type: 'answer',
        content_purpose_document_supertype: 'guide',
        first_published_at: Time.new(2012, 10, 3, 13, 19, 55),
        public_updated_at: Time.new(2015, 6, 3, 11, 13, 44),
        primary_organisation_title: 'Home Office',
        primary_organisation_content_id: 'cont-id-1',
        primary_organisation_withdrawn: false,
        content_hash: parsed_content_hash,
      )
    end

    it 'leaves the older versions alone' do
      subject.run

      expect(older_dimension_item.reload.raw_json).to eq nil
    end

    it 'updates the latest item attributes' do
      expect(Items::Jobs::ImportQualityMetricsJob).to receive(:perform_async)

      subject.run

      expect(latest_dimension_item.reload).to have_attributes(
        raw_json: raw_json,
        number_of_pdfs: 99,
        number_of_word_files: 94,
        content_id: '09hjasdfoj234',
        title: 'A guide to coding',
        document_type: 'answer',
        content_purpose_document_supertype: 'guide',
        first_published_at: Time.new(2012, 10, 3, 13, 19, 55),
        public_updated_at: Time.new(2015, 6, 3, 11, 13, 44),
        primary_organisation_title: 'Home Office',
        primary_organisation_content_id: 'cont-id-1',
        primary_organisation_withdrawn: false,
        content_hash: parsed_content_hash,
      )
    end

    context 'without fetching quality metrics' do
      subject { Items::Importers::ContentDetails.new(latest_dimension_item.id, quality_metrics: false) }

      it "doesn't update facts for events we don't care about" do
        expect(Items::Jobs::ImportQualityMetricsJob).not_to receive(:perform_async)

        subject.run
      end
    end

    context "when the locale is 'en'" do
      let(:locale) { 'en' }

      context 'and the content has changed' do
        let(:parsed_content_hash) { 'ADifferentContentHash' }
        it 'triggers a quality metrics job' do
          subject.run
          expect(Items::Jobs::ImportQualityMetricsJob).to have_received(:perform_async).with(latest_dimension_item.id)
          expect(Items::Jobs::ImportQualityMetricsJob).not_to have_received(:perform_async).with(latest_dimension_item_fr.id)
        end
      end

      context 'and the content has not changed' do
        let(:parsed_content_hash) { existing_content_hash }
        it "doesn't run a quality metrics job" do
          subject.run
          expect(Items::Jobs::ImportQualityMetricsJob).not_to have_received(:perform_async)
        end
      end
    end

    context "when the locale is not 'en' and the content has changed" do
      let(:locale) { 'fr' }
      let(:parsed_content_hash) { 'ADifferentContentHash' }
      it "doesn't run a quality metrics job" do
        subject.run
        expect(Items::Jobs::ImportQualityMetricsJob).not_to have_received(:perform_async).with(latest_dimension_item.id)
        expect(Items::Jobs::ImportQualityMetricsJob).not_to have_received(:perform_async).with(latest_dimension_item_fr.id)
      end
    end
  end

  context 'when GdsApi::HTTPGone is raised' do
    subject { Items::Importers::ContentDetails.new(existing_content_item.id) }
    let(:locale) { 'en' }
    let!(:existing_content_item) { create :dimensions_item, content_id: content_id, status: 'something', locale: locale }

    before :each do
      expect(subject.content_store_client).to receive(:fetch_raw_json).and_raise(GdsApi::HTTPGone.new(410))

      subject.run
    end

    it 'should set the status to gone' do
      expect(existing_content_item.reload.status).to eq('gone')
    end
  end

  context 'when GdsApi::HTTPNotFound is raised' do
    subject { Items::Importers::ContentDetails.new(existing_content_item.id) }
    let(:locale) { 'en' }
    let!(:existing_content_item) do
      create :dimensions_item, content_id: content_id, status: 'something', raw_json: { existing: 'content' }
    end

    before :each do
      expect(subject.content_store_client).to receive(:fetch_raw_json).and_raise(GdsApi::HTTPNotFound.new(404))

      subject.run
    end

    it 'should set leave everything alone' do
      existing_content_item.reload
      expect(existing_content_item.status).to eq('something')
      expect(existing_content_item.raw_json).to eq('existing' => 'content')
    end
  end
end
