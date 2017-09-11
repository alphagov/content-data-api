module Audits
  class FindTeamAuditors
    def self.call(*args)
      new(*args).call
    end

    attr_reader :user

    def initialize(organisation_slug:)
      @organisation_slug = organisation_slug
    end

    def call
      User
        .where(organisation_slug: organisation_slug)
        .distinct
    end
  end
end
