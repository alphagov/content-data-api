RSpec.describe Streams::Handlers::SingleItemHandler do
  let(:content_id) { SecureRandom.uuid }
  let(:base_path) { "/base-path" }
  let(:locale) { "en" }

  let(:old_edition) do
    create(
      :edition,
      content_id:,
      base_path:,
      locale: "en",
      live: true,
    )
  end

  subject { described_class.new(attrs, {}, "routing_key") }

  context "when attrs match the old edition" do
    let(:attrs) do
      old_edition
        .attributes
        .slice("content_id", "base_path", "locale", "warehouse_item_id")
        .symbolize_keys
    end

    context "with a single english edition" do
      it "finds the old english edition when no attributes change" do
        expect(subject).to receive(:update_editions).with(
          [attrs:, old_edition:],
        )

        subject.process
      end
    end

    context "with a single welsh edition" do
      let(:base_path) { "/base-path.cy" }
      let(:locale) { "cy" }

      it "finds the old welsh edition when no attributes change" do
        expect(subject).to receive(:update_editions).with(
          [attrs:, old_edition:],
        )

        subject.process
      end
    end
  end

  context "when attrs differ from the old edition" do
    context "in the case of a redirect or gone with no locale" do
      let(:attrs) do
        {
          content_id:,
          base_path:,
        }
      end

      it "raises an error" do
        expect { subject.process }.to raise_error(
          Streams::Handlers::SingleItemHandler::MissingLocaleError,
        )
      end
    end
  end
end
