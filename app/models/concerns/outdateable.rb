require 'active_support/concern'

module Concerns::Outdateable
  extend ActiveSupport::Concern

  included do
    scope :outdated, -> { where(outdated: true, latest: true) }
    scope :outdated_before, ->(date) { outdated.where('outdated_at < ?', date) }

    def outdate!(base_path:)
      update_attributes!(outdated: true, outdated_at: Time.zone.now, base_path: base_path)
    end
  end
end
