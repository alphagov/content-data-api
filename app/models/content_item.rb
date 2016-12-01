class ContentItem < ApplicationRecord
  belongs_to :organisation

  def url
    "https://gov.uk#{self.link}"
  end
end
