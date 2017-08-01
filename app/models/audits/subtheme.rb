module Audits
  class Subtheme < ApplicationRecord
    default_scope { order(:name) }

    belongs_to :theme
    has_many :inventory_rules

    validates :name,
      presence: true,
      uniqueness: { scope: :theme, case_sensitive: false }
  end
end
