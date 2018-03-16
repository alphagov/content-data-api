require 'gds_api/test_helpers/content_store'

RSpec.describe ItemsService do
  include GdsApi::TestHelpers::ContentStore

  let(:publishing_api_client) { double('publishing_api_client') }

  before do
    subject.publishing_api_client = publishing_api_client
  end

  describe "#fetch_all_with_default_locale_only" do
    let(:editions) do
      [
        { content_id: "a", locale: "en" },
        { content_id: "a", locale: "cy" },

        { content_id: "b", locale: "cy" },
        { content_id: "b", locale: "en" },

        { content_id: "c", locale: "cy" },
        { content_id: "c", locale: "cs" },
      ]
    end
    let(:fields) { %w[content_id locale user_facing_version] }

    before do
      allow(publishing_api_client).to receive(:fetch_all)
        .with(fields)
        .and_return(editions)
    end

    it "only returns one of each content id" do
      content_ids = subject.fetch_all_with_default_locale_only(fields)
        .map { |content_item| content_item[:content_id] }
      expect(content_ids).to contain_exactly("a", "b", "c")
    end

    it "returns 'en' locales where available" do
      expect(subject.fetch_all_with_default_locale_only(fields)).to include(
        { content_id: "a", locale: "en" },
        content_id: "b", locale: "en",
      )
    end

    it "returns the first locale if 'en' is not available" do
      expect(subject.fetch_all_with_default_locale_only(fields)).to include(
        content_id: "c", locale: "cy"
      )
    end
  end

  describe "#fetch_raw_json" do
    it "returns a hash with the content item attributes" do
      content_store_has_item('/the-base-path', { the: :body }, {})

      expect(subject.fetch_raw_json('/the-base-path')).to eq('the' => 'body')
    end
  end
end
