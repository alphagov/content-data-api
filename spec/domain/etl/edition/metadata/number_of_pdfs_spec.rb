require 'gds_api/test_helpers/content_store'

module Performance
  RSpec.describe Etl::Edition::Metadata::NumberOfPdfs do
    include GdsApi::TestHelpers::ContentStore

    subject { described_class }

    context 'when the pdf links are under details > documents' do
      it "returns the number of pdfs present" do
        response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"link.pdf\">1</a>\n\n\n\n</div>')
        expect(subject.parse(response)).to eq(1)
      end

      it "returns 0 if no pdfs are present" do
        response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"link.txt\">1</a>\n\n\n\n</div>')
        expect(subject.parse(response)).to eq(0)
      end

      it "returns 0 if no document keys are present" do
        expect(subject.parse({})).to eq(0)
      end

      it "returns 0 if the details is nil" do
        expect(subject.parse({})).to eq(0)
      end

      it "returns 0 if the attachment ends with `pdf`, but with no `dot`" do
        response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"linkpdf\">1</a>\n\n\n\n</div>')
        expect(subject.parse(response)).to eq(0)
      end

      it "returns 0 if the attachment file extension starts with `.pdf`, but ends with 'p'" do
        response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"link.pdfp\">1</a>\n\n\n\n</div>')
        expect(subject.parse(response)).to eq(0)
      end

      it "returns 1 if the attachment file is `.PDF`" do
        response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"link.PDF\">1</a>\n\n\n\n</div>')
        expect(subject.parse(response)).to eq(1)
      end
    end

    context 'when the pdf links are under details > body' do
      it 'returns 1 if the container has the class `form-download`' do
        response = build_response('body' => '<div class=\"form-download">\n<p><a href=\"link.pdf\">1</a></p>\n\n\n\n</div>')
        expect(subject.parse(response)).to eq(1)
      end

      it 'returns 2 if a container with the class `form-download` contains 2 links' do
        body = '<div class=\"form-download">\n<p><a href=\"link.pdf\">1</a></p><p><a href=\"link2.pdf\">2</a></p>\n\n\n\n</div>'
        response = build_response('body' => body)
        expect(subject.parse(response)).to eq(2)
      end

      it 'returns 0 if the container has a class other than `form-download` or `attachment-details`' do
        response = build_response('body' => '<div class=\"another-download">\n<p><a href=\"link.pdf\">1</a></p>\n\n\n\n</div>')
        expect(subject.parse(response)).to eq(0)
      end
    end

    def build_response(details)
      content_item_for_base_path('/a-base-path').merge('details' => details)
    end
  end
end
