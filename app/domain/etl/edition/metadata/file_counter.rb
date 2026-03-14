class Etl::Edition::Metadata::FileCounter
  ALL_LINKS_XPATH = "//*[contains(@class, 'attachment-details') or contains(@class, 'form-download')]//a/@href".freeze

  def initialize(body)
    @body = body
  end

  def pdf_count
    count_files(%w[pdf])
  end

  def doc_count
    count_files(%w[doc docx docm])
  end

private

  def count_files(extensions)
    count_matching_attachments(extensions).to_i.nonzero? || count_matching_html_links(extensions)
  end

  def count_matching_attachments(extensions)
    return 0 unless attachments

    file_extensions = extensions.map { |ext| ".#{ext}".downcase }
    filenames_from_attachments.select { |filename| File.extname(filename).in?(file_extensions) }.count
  end

  def filenames_from_attachments
    attachments.map { |attachment| attachment["filename"]&.downcase }.compact
  end

  def attachments
    @attachments ||= @body.dig("details", "attachments")
  end

  def count_matching_html_links(extensions)
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
