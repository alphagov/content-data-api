require 'active_support/concern'

module Concerns::Outdateable
  extend ActiveSupport::Concern

  included do
    scope :outdated, -> { where(outdated: true) }
    scope :outdated_before, ->(date) { outdated.where('outdated_at < ?', date) }

    def outdate!
      update_attributes!(outdated: true, outdated_at: Time.zone.now)
    end
  end
end
