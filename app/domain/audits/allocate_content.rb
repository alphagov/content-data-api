module Audits
  class AllocateContent
    def self.call(*args)
      new(*args).call
    end

    attr_accessor :user_uid, :content_ids

    def initialize(user_uid:, content_ids:)
      self.user_uid = user_uid
      self.content_ids = content_ids
    end

    def call
      Allocation.transaction { create_or_update_allocation! }

      AllocationResult.new(user.name, content_ids.count)
    end

  private

    def create_or_update_allocation!
      Allocation.where(content_id: content_ids).delete_all

      allocations = content_ids.map do |content_id|
        { uid: user_uid, content_id: content_id }
      end

      Allocation.import(allocations, validate: false)
    end

    def user
      @user ||= User.find_by(uid: user_uid)
    end
  end
end
