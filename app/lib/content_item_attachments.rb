class ContentItemAttachments
  class << self
    PDF_THRESHOLD = 1
    PDF_XPATH = "//*[contains(@class, 'attachment-details')]//a[contains(@href, '.pdf')]".freeze

    def pdfs?(html_string)
      pdfs(parse(html_string)).length >= PDF_THRESHOLD
    end

  private

    def parse(html_string)
      Nokogiri::HTML(html_string)
    end

    def pdfs(html_fragment)
      html_fragment.xpath(PDF_XPATH)
    end
  end
end
