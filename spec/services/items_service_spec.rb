require 'gds_api/test_helpers/content_store'

RSpec.describe ItemsService do
  include GdsApi::TestHelpers::ContentStore

  describe "#fetch_raw_json" do
    it "returns a hash with the content item attributes" do
      content_store_has_item('/the-base-path', { the: :body }, {})

      expect(subject.fetch_raw_json('/the-base-path')).to eq('the' => 'body')
    end
  end
end
