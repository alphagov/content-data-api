require 'sidekiq/testing'
RSpec.describe 'Import edition metrics' do
  subject { Streams::Consumer.new }

  it 'stores content edition metrics' do
    message = build(:message, schema_name: 'publication', base_path: '/new-path')
    message.payload['details']['body'] = 'This is good content.'
    message.payload['details']['documents'] = [
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
      words: 4
    )
  end

  let(:existing_quality_metrics) do
    {
      words: 3,
    }
  end

  def find_latest_edition(base_path)
    Dimensions::Edition.latest_by_base_path([base_path]).first.facts_edition
  end
end
