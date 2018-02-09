require 'gds_api/test_helpers/content_store'

RSpec.describe Importers::ContentDetails do
  include GdsApi::TestHelpers::ContentStore

  subject { Importers::ContentDetails.new(latest_dimension_item.content_id, latest_dimension_item.base_path) }

  context 'Import contents' do
    let(:base_path) { '/base_path' }
    let(:latest_dimension_item) { create(:dimensions_item, latest: true, raw_json: nil) }
    let(:older_dimension_item) do
      create(:dimensions_item, content_id: latest_dimension_item.content_id,
                               base_path: latest_dimension_item.base_path,
                               latest: false,
                               raw_json: nil)
    end
    let(:content_store_response) { content_item_for_base_path(base_path) }

    it 'populates raw_json field of latest version of dimensions_items' do
      allow(subject.items_service).to receive(:fetch_raw_json)
      .and_return(content_store_response)
      subject.run
      expect(latest_dimension_item.reload.raw_json).to eq content_store_response
      expect(older_dimension_item.reload.raw_json).to eq nil
    end
  end
end
