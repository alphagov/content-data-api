require "sidekiq/testing"
RSpec.describe "Import edition metrics" do
  # FIXME: Rails 6 inconsistently overrides ActiveJob queue_adapter setting
  # with TestAdapter #37270
  # See https://github.com/rails/rails/issues/37270
  around do |example|
    perform_enqueued_jobs { example.run }
  end

  subject { Streams::Consumer.new }

  it "stores content edition metrics" do
    message = build(:message, schema_name: "publication", base_path: "/new-path")
    message.payload["details"]["body"] = "This is good content."
    message.payload["details"]["documents"] = [
      '<div class=\"attachment-details\">\n<a href=\"link.pdf\">1</a>\n\n\n\n</div>',
      '<div class=\"attachment-details\">\n<a href=\"link.docx\">1</a>\n\n\n\n</div>',
    ]

    subject.process(message)

    edition = Dimensions::Edition.first
    expect(edition.facts_edition).to have_attributes(
      pdf_count: 1,
      doc_count: 1,
      readability: 97,
      chars: 21,
      sentences: 1,
      words: 4,
    )
  end

  let(:existing_quality_metrics) do
    {
      words: 3,
    }
  end

  def find_live_edition(base_path)
    Dimensions::Edition.live_by_base_path([base_path]).first.facts_edition
  end
end
