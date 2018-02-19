module Performance::Metrics
  class NumberOfPdfs
    attr_accessor :content_item

    PDF_XPATH = "//*[contains(@class, 'attachment-details')]//a[contains(@href, '.pdf')]".freeze

    def initialize(content_item)
      @content_item = content_item
    end

    def run
      documents_string = NumberOfFiles.extract_documents(content_item.details)
      documents = NumberOfFiles.parse documents_string
      { number_of_pdfs: NumberOfFiles.number_of_files(documents, PDF_XPATH) }
    end

    def self.parse(details)
      documents_string = NumberOfFiles.extract_documents(details)
      documents = NumberOfFiles.parse documents_string
      NumberOfFiles.number_of_files(documents, PDF_XPATH)
    end
  end
end
