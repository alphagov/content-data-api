module Performance::Metrics
  class NumberOfWordFiles
    attr_accessor :content_item

    DOC_XPATH = "//*[contains(@class, 'attachment-details')]//a[contains(@href, '.doc')]".freeze

    def initialize(content_item)
      @content_item = content_item
    end

    def run
      documents_string = NumberOfFiles.extract_documents(content_item.details)
      documents = NumberOfFiles.parse documents_string
      { number_of_word_files: NumberOfFiles.number_of_files(documents, DOC_XPATH) }
    end
  end
end
