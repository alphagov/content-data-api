class ContentItem < ApplicationRecord
  belongs_to :organisation

  def url
    "https://gov.uk#{self.base_path}"
  end
end
