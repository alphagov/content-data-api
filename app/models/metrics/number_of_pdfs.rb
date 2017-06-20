module Metrics
  class NumberOfPdfs
    attr_accessor :content_item

    PDF_XPATH = "//*[contains(@class, 'attachment-details')]//a[contains(@href, '.pdf')]".freeze

    def initialize(content_item)
      @content_item = content_item
    end

    def run
      documents_string = extract_documents
      documents = parse documents_string
      { number_of_pdfs: number_of_pdfs(documents) }
    end

  private

    def extract_documents
      if content_item.details.is_a?(Hash)
        details = content_item.details.symbolize_keys
        documents = document_keys.map do |k|
          details.fetch(k, nil)
        end
        documents.join('')
      end
    end

    def document_keys
      %i(documents final_outcome_documents)
    end

    def parse(string)
      Nokogiri::HTML(string)
    end

    def number_of_pdfs(html_fragment)
      html_fragment.xpath(PDF_XPATH).length
    end
  end
end
