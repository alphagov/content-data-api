module Clients
  class ContentStore
    class << self
      def find(path, attributes)
        response = HTTParty.get(end_point(path))
        content_item = JSON.parse(response.body).symbolize_keys

        content_item.slice(*attributes)
      end

    private

      def end_point(base_path)
        "https://www.gov.uk/api/content#{base_path}"
      end
    end
  end
end
