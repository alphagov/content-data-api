require "gds_api/test_helpers/content_store"

module Performance
  RSpec.describe Etl::Edition::Metadata::FileCounter do
    include GdsApi::TestHelpers::ContentStore

    shared_examples "document file counter" do |counter_method:, matching_extensions:, non_matching:, no_dot:, near_miss:|
      %w[documents body].each do |section|
        context "when links are under details > #{section}" do
          matching_extensions.each do |extension|
            it "counts .#{extension} files" do
              response = build_response(section => attachment_container("attachment-details", "link.#{extension}"))
              expect(described_class.new(response).public_send(counter_method)).to eq(1)
            end

            it "counts links in a form-download container" do
              response = build_response(section => attachment_container("form-download", "link.#{extension}"))
              expect(described_class.new(response).public_send(counter_method)).to eq(1)
            end

            it "counts multiple links in a form-download container" do
              response = build_response(section => attachment_container("form-download", "link.#{extension}", "link2.#{extension}"))
              expect(described_class.new(response).public_send(counter_method)).to eq(2)
            end

            it "returns 0 for other container classes" do
              response = build_response(section => attachment_container("another-download", "link.#{extension}"))
              expect(described_class.new(response).public_send(counter_method)).to eq(0)
            end
          end

          it "returns 0 for non-matching files" do
            response = build_response(section => attachment_container("attachment-details", "link.#{non_matching}"))
            expect(described_class.new(response).public_send(counter_method)).to eq(0)
          end

          it "returns 0 when the extension has no dot" do
            response = build_response(section => attachment_container("attachment-details", "link#{no_dot}"))
            expect(described_class.new(response).public_send(counter_method)).to eq(0)
          end

          it "returns 0 for partial extension matches" do
            response = build_response(section => attachment_container("attachment-details", "link.#{near_miss}"))
            expect(described_class.new(response).public_send(counter_method)).to eq(0)
          end
        end
      end

      context "when attachments are present in the response" do
        matching_extensions.each do |extension|
          it "counts #{extension} attachments by filename" do
            response = build_response("attachments" => [
              { "filename" => "document.#{extension}" },
              { "filename" => "report.#{extension}" },
            ])
            expect(described_class.new(response).public_send(counter_method)).to eq(2)
          end

          it "prefers structured attachments over html parsing" do
            response = build_response(
              "attachments" => [{ "filename" => "document.#{extension}" }],
              "body" => attachment_container("attachment-details", "link.#{extension}", "link2.#{extension}"),
            )
            expect(described_class.new(response).public_send(counter_method)).to eq(1)
          end

          it "ignores attachments without filename key" do
            response = build_response("attachments" => [
              { "title" => "document" },
              { "filename" => "report.#{extension}" },
            ])
            expect(described_class.new(response).public_send(counter_method)).to eq(1)
          end

          it "attempts to parse the body if there are no attachments" do
            response = build_response(
              "attachments" => [],
              "body" => attachment_container("attachment-details", "link.#{extension}", "link2.#{extension}"),
            )
            expect(described_class.new(response).public_send(counter_method)).to eq(2)
          end
        end

        it "returns 0 for non-matching files" do
          response = build_response("attachments" => [
            { "filename" => "document.#{non_matching}" },
          ])
          expect(described_class.new(response).public_send(counter_method)).to eq(0)
        end

        it "returns 0 when the extension has no dot" do
          response = build_response("attachments" => [
            { "filename" => "document#{no_dot}" },
          ])
          expect(described_class.new(response).public_send(counter_method)).to eq(0)
        end

        it "returns 0 for partial extension matches" do
          response = build_response("attachments" => [
            { "filename" => "document.#{near_miss}" },
          ])
          expect(described_class.new(response).public_send(counter_method)).to eq(0)
        end

        it "returns 0 for empty attachments array" do
          response = build_response("attachments" => [])
          expect(described_class.new(response).pdf_count).to eq(0)
        end
      end

      it "returns 0 when details is an empty hash" do
        expect(described_class.new(build_response({})).public_send(counter_method)).to eq(0)
      end

      it "returns 0 when details is nil" do
        expect(described_class.new(build_response(nil)).public_send(counter_method)).to eq(0)
      end
    end

    describe "#pdf_count" do
      context "when pdf links are under details > documents" do
        it_behaves_like "document file counter",
                        counter_method: :pdf_count,
                        matching_extensions: %w[pdf PDF],
                        non_matching: "txt",
                        no_dot: "pdf",
                        near_miss: "pdfp"
      end
    end

    describe "#doc_count" do
      it_behaves_like "document file counter",
                      counter_method: :doc_count,
                      matching_extensions: %w[doc docm docx],
                      non_matching: "txt",
                      no_dot: "doc",
                      near_miss: "docn"
    end

    def attachment_container(css_class, *hrefs)
      links = hrefs.map.with_index(1) { |href, index| %(<a href="#{href}">#{index}</a>) }.join
      %(<div class="#{css_class}">#{links}</div>)
    end

    def build_response(details)
      content_item_for_base_path("/a-base-path").merge("details" => details)
    end
  end
end
