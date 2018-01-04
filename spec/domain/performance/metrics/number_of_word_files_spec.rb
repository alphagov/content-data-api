module Performance
  RSpec.describe Metrics::NumberOfWordFiles do
    subject { Metrics::NumberOfWordFiles }

    let(:content_with_word_files) {
      build(:content_item, details: {
        documents: [
          '<div class=\"attachment-details\">\n<a href=\"link.docx\">1</a>\n\n\n\n</div>',
          '<div class=\"attachment-details\">\n<a href=\"link.docx\">1</a>\n\n\n\n</div>',
        ],
        final_outcome_documents: [
          '<div class=\"attachment-details\">\n<a href=\"link.docx\">1</a>\n\n\n\n</div>',
        ]
      })
    }
    let(:content_without_word_files) {
      build(:content_item, details: {
        details: {
          "documents" => [
            '<div class=\"attachment-details\">\n<a href=\"link.pdf\">1</a>\n\n\n\n</div>',
          ]
        }
      })
    }
    let(:content_without_document_keys) { build(:content_item, details: {}) }
    let(:content_without_details_key) { build(:content_item) }

    it "returns the number of word files present" do
      expect(subject.new(content_with_word_files).run).to eq(number_of_word_files: 3)
    end

    it "returns 0 if no pdfs are present" do
      expect(subject.new(content_without_word_files).run).to eq(number_of_word_files: 0)
    end

    it "returns 0 if no document keys are present" do
      expect(subject.new(content_without_document_keys).run).to eq(number_of_word_files: 0)
    end

    it "returns 0 if the 'details' key is not present" do
      expect(subject.new(content_without_details_key).run).to eq(number_of_word_files: 0)
    end
  end
end
