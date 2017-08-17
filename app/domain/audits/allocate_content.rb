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
      Allocation.transaction { create_or_update_allocation! }

      Result.new(user, content_items)
    end

  private

    def create_or_update_allocation!
      Allocation.where(content_item: content_items).delete_all
      content_items.find_each do |item|
        Allocation.create(user: user, content_item: item)
      end
    end

    class Result
      attr_reader :user, :content_items

      def initialize(user, content_items)
        @user = user
        @content_items = content_items
      end

      def message
        "#{content_items.count} items allocated to #{user.name}"
      end
    end
  end
end
