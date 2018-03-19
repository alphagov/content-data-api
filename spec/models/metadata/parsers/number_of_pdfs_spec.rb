require 'gds_api/test_helpers/content_store'
module Performance
  RSpec.describe Metadata::Parsers::NumberOfPdfs do
    include GdsApi::TestHelpers::ContentStore
    subject { Metadata::Parsers::NumberOfPdfs }

    let(:response_without_document_keys) do
      {
        details: {}
      }.to_json
    end
    let(:response_without_details_key) do
      {}.to_json
    end
    let(:content_store_response) { content_item_for_base_path('/base_path') }


    def response_with_document_key(document = nil)
      {
        details: {
          document: document
        }
      }.to_json
    end

    context "#parse" do
      it "returns the number of pdfs present" do
        details = {
          'documents' => '<div class=\"attachment-details\">\n<a href=\"link.pdf\">1</a>\n\n\n\n</div>'
        }

        expect(subject.parse('details' => details)).to eq(number_of_pdfs: 1)
      end

      it "returns 0 if no pdfs are present" do
        details = {
          'documents' => '<div class=\"attachment-details\">\n<a href=\"link.txt\">1</a>\n\n\n\n</div>'
        }

        expect(subject.parse('details' => details)).to eq(number_of_pdfs: 0)
      end

      it "returns 0 if no document keys are present" do
        expect(subject.parse('details' => {})).to eq(number_of_pdfs: 0)
      end

      it "returns 0 if the details is nil" do
        expect(subject.parse({})).to eq(number_of_pdfs: 0)
      end
    end
  end
end
