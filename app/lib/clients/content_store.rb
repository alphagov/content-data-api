module Clients
  class ContentStore
    def fetch(path, attributes)
      response = HTTParty.get(end_point(path))
      content_item = JSON.parse(response.body).with_indifferent_access

      content_item.slice(*attributes)
    end

  private

    def end_point(base_path)
      "https://www.gov.uk/api/content#{base_path}"
    end
  end
end
