class InventoryRule < ApplicationRecord
  belongs_to :subtheme

  validates :link_type, presence: true
  validates :target_content_id,
    presence: true,
    uniqueness: { scope: %i(subtheme link_type), case_sensitive: false }
end
