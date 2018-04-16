require 'gds_api/test_helpers/content_store'
module Performance
  RSpec.describe Item::Metadata::Parsers::NumberOfPdfs do
    include GdsApi::TestHelpers::ContentStore

    subject { described_class }

    it "returns the number of pdfs present" do
      response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"link.pdf\">1</a>\n\n\n\n</div>')
      expect(subject.parse(response)).to eq(number_of_pdfs: 1)
    end

    it "returns 0 if no pdfs are present" do
      response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"link.txt\">1</a>\n\n\n\n</div>')
      expect(subject.parse(response)).to eq(number_of_pdfs: 0)
    end

    it "returns 0 if no document keys are present" do
      expect(subject.parse({})).to eq(number_of_pdfs: 0)
    end

    it "returns 0 if the details is nil" do
      expect(subject.parse({})).to eq(number_of_pdfs: 0)
    end

    it "returns 0 if the attachment ends with `pdf`, but with no `dot`" do
      response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"linkpdf\">1</a>\n\n\n\n</div>')
      expect(subject.parse(response)).to eq(number_of_pdfs: 0)
    end

    it "returns 0 if the attachment file extension starts with `.pdf`, but ends with 'p'" do
      response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"link.pdfp\">1</a>\n\n\n\n</div>')
      expect(subject.parse(response)).to eq(number_of_pdfs: 0)
    end

    def build_response(details)
      content_item_for_base_path('/a-base-path').merge('details' => details)
    end
  end
end
