class ContentItem < ApplicationRecord
  has_and_belongs_to_many :organisations

  def url
    "https://gov.uk#{base_path}"
  end
end
