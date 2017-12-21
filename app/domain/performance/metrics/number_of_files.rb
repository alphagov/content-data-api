module Performance::Metrics::NumberOfFiles
  def self.extract_documents(content_item_details)
    if content_item_details.is_a?(Hash)
      details = content_item_details.symbolize_keys
      documents = document_keys.map do |k|
        details.fetch(k, nil)
      end
      documents.join('')
    end
  end

  def self.document_keys
    %i(documents final_outcome_documents)
  end

  def self.parse(string)
    Nokogiri::HTML(string)
  end

  def self.number_of_files(html_fragment, path)
    html_fragment.xpath(path).length
  end
end
