class Etl::Edition::Metadata::FileCounter
  ALL_LINKS_XPATH = "//*[contains(@class, 'attachment-details') or contains(@class, 'form-download')]//a/@href".freeze

  def initialize(body)
    @body = body
  end

  def pdf_count
    filter_html_links(%w[pdf])
  end

  def doc_count
    filter_html_links(%w[doc docx docm])
  end

private

  def filter_html_links(extensions)
    # Sample: \.(doc|docx|docm)$
    regex = /\.(#{extensions.join('|')})$/i

    all_links_from_html.grep(regex).length
  end

  def all_links_from_html
    @all_links_from_html ||= begin
      all_links = document&.xpath(ALL_LINKS_XPATH)
      all_links&.map { |node| node.value.gsub('\\"', "") }
    end
  end

  def document
    @document ||= begin
      return nil unless @body.is_a?(Hash)

      document_keys = %w[documents final_outcome_documents body]
      document = document_keys.map { |key| @body.dig("details", key) }

      Nokogiri::HTML(document.join(""))
    end
  end
end
