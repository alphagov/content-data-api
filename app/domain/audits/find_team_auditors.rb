module Audits
  class FindTeamAuditors
    def self.call(*args)
      new(*args).call
    end

    attr_reader :user

    def initialize(user_uid:)
      @user = User.find_by uid: user_uid
    end

    def call
      User
        .joins("INNER JOIN allocations ON allocations.uid = users.uid")
        .where(organisation_slug: user.organisation_slug)
        .distinct
        .to_a
    end
  end
end
