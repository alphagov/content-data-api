RSpec.describe Importers::ContentDetails do
  let(:base_path) { '/base_path' }
  let(:content_id) { 'content_id' }

  subject { Importers::ContentDetails.new(content_id, base_path) }

  context 'Import contents' do
    let!(:latest_dimension_item) { create(:dimensions_item, content_id: content_id, base_path: base_path, latest: true, raw_json: nil) }
    let!(:older_dimension_item) { create(:dimensions_item, content_id: content_id, base_path: base_path, latest: false, raw_json: nil) }

    before do
      allow(subject.items_service).to receive(:fetch_raw_json).and_return('details' => 'the-json')
      allow_any_instance_of(Dimensions::Item).to receive(:get_content).and_return('the-entire-body')
      allow(ImportQualityMetricsJob).to receive(:perform_async)
      allow(subject.content_quality_service).to receive(:run).with('the-entire-body').and_return(
        readability_score: 1,
        contractions_count: 2,
        equality_count: 3,
        indefinite_article_count: 4,
        passive_count: 5,
        profanities_count: 6,
        redundant_acronyms_count: 7,
        repeated_words_count: 8,
        simplify_count: 9,
        spell_count: 10
      )
    end

    it 'populates raw_json field of latest version of dimensions_items' do
      subject.run

      expect(latest_dimension_item.reload.raw_json).to eq 'details' => 'the-json'
      expect(older_dimension_item.reload.raw_json).to eq nil
    end

    it 'stores the number of PDF attachments' do
      allow(Performance::Metrics::NumberOfPdfs).to receive(:parse).with('the-json').and_return(99)

      subject.run
      expect(latest_dimension_item.reload.number_of_pdfs).to eq 99
    end

    it 'stores the number of Word file attachments' do
      allow(Performance::Metrics::NumberOfWordFiles).to receive(:parse).with('the-json').and_return(94)

      subject.run
      expect(latest_dimension_item.reload.number_of_word_files).to eq 94
    end

    it 'triggers a quality metrics job' do
      expect(ImportQualityMetricsJob).to receive(:perform_async).with(latest_dimension_item.id)
      subject.run
    end

    it 'populates the metadata' do
      allow(subject.items_service).to receive(:fetch_raw_json).and_return(
        'content_id' => '09hjasdfoj234',
        'title' => 'A guide to coding',
        'document_type' => 'answer',
        'content_purpose_document_supertype' => 'guide',
        'first_published_at' => '2012-10-03T13:19:55.000+00:00',
        'public_updated_at' => '2015-06-03T11:13:44.000+00:00',
      )

      subject.run
      latest_dimension_item.reload
      expect(latest_dimension_item.title).to eq('A guide to coding')
      expect(latest_dimension_item.content_id).to eq('09hjasdfoj234')
      expect(latest_dimension_item.document_type).to eq('answer')
      expect(latest_dimension_item.content_purpose_document_supertype).to eq('guide')
      expect(latest_dimension_item.first_published_at).to eq(Time.new.strftime('2012-10-03T13:19:55.000+00:00'))
      expect(latest_dimension_item.public_updated_at).to eq(Time.new.strftime('2015-06-03T11:13:44.000+00:00'))
    end

    it 'populates the primary_organisation' do
      allow(subject.items_service).to receive(:fetch_raw_json).and_return(
        'links' => {
          'primary_publishing_organisation' => [{
            'title' => 'Home Office',
            'content_id' => 'cont-id-1',
            'withdrawn' => false
          }]
        }
      )
      subject.run
      expect(latest_dimension_item.reload).to have_attributes(
        primary_organisation_title: 'Home Office',
        primary_organisation_content_id: 'cont-id-1',
        primary_organisation_withdrawn: false
      )
    end
  end

  context 'when GdsApi::HTTPGone is raised' do
    let!(:existing_content_item) { create :dimensions_item, content_id: content_id, status: 'something' }

    before :each do
      expect(subject.items_service).to receive(:fetch_raw_json).and_raise(GdsApi::HTTPGone.new(410))

      subject.run
    end

    it 'should set the status to gone' do
      expect(existing_content_item.reload.status).to eq('gone')
    end
  end

  context 'when GdsApi::HTTPNotFound is raised' do
    let!(:existing_content_item) do
      create :dimensions_item, content_id: content_id, status: 'something', raw_json: { existing: 'content' }
    end

    before :each do
      expect(subject.items_service).to receive(:fetch_raw_json).and_raise(GdsApi::HTTPNotFound.new(404))

      subject.run
    end

    it 'should set leave everything alone' do
      existing_content_item.reload
      expect(existing_content_item.status).to eq('something')
      expect(existing_content_item.raw_json).to eq('existing' => 'content')
    end
  end
end
