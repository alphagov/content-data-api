module Audits
  class AllocateContent
    def self.call(*args)
      new(*args).call
    end

    attr_accessor :user, :content_items

    def initialize(user_uid:, content_ids:)
      self.user = User.find_by(uid: user_uid)
      self.content_items = Content::Item.where(content_id: content_ids)
    end

    def call
      content_items.find_each do |content_item|
        allocation = Allocation.find_by(content_item: content_item)
        if allocation
          allocation.update!(user: user, content_item: content_item)
        else
          Allocation.create!(user: user, content_item: content_item)
        end
      end
    end
  end
end
