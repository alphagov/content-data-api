class ContentItem < ApplicationRecord
  belongs_to :organisation

  def url
    "https://gov.uk#{base_path}"
  end
end
