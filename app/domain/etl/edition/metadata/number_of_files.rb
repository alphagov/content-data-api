module Etl::Edition::Metadata::NumberOfFiles
  def self.number_of_files(body, extensions_regex)
    documents = extract_documents(body)
    all_links = all_links(documents)
    filter_links all_links, extensions_regex
  end

  ALL_LINKS_XPATH = "//*[contains(@class, 'attachment-details') or contains(@class, 'form-download')]//a/@href".freeze

  def self.extract_documents(content_item_details)
    return nil unless content_item_details.is_a?(Hash)

    document_keys = %w[documents final_outcome_documents body]
    document = document_keys.map { |key| content_item_details.dig("details", key) }

    Nokogiri::HTML(document.join(""))
  end

  def self.all_links(documents)
    all_links = documents.xpath(ALL_LINKS_XPATH)
    all_links.map { |node| node.value.gsub('\\"', "") }
  end

  def self.filter_links(all_links, extensions_regex)
    # Sample: \.(doc|docx|docm)$
    regex = /\.(#{extensions_regex.join('|')})$/i

    all_links.grep(regex).length
  end
end
