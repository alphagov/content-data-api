RSpec.describe Importers::ContentDetails do
  let(:base_path) { '/base_path' }
  let(:content_id) { 'content_id' }

  subject { Importers::ContentDetails.new(content_id, base_path) }

  context 'Import contents' do
    let!(:latest_dimension_item) { create(:dimensions_item, content_id: content_id, base_path: base_path, latest: true, raw_json: nil) }
    let!(:older_dimension_item) { create(:dimensions_item, content_id: content_id, base_path: base_path, latest: false, raw_json: nil) }

    before do
      allow(subject.items_service).to receive(:fetch_raw_json).and_return('details' => 'the-json')
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
  end
end
