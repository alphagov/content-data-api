module Audits
  class SaveAudit
    def self.call(*args)
      new(*args).call
    end

    attr_reader :attributes
    attr_accessor :audit, :content_item, :success, :user

    def attributes=(attribute)
      @attributes = attribute.to_h
    end

    def initialize(attributes:, content_id:, user_uid:)
      self.attributes = attributes
      self.content_item = Content::Item.find_by!(content_id: content_id)
      self.audit = Audits::Audit.find_or_initialize_by(content_item: content_item)
      self.user = User.find_by(uid: user_uid)
    end

    def call
      audit.content_item = content_item
      audit.user = user

      clear_redirect_urls_if_not_redundant
      clear_similar_urls_if_not_similar
      success = audit.update(attributes)

      Result.new(
        audit,
        content_item,
        success
      )
    end

    class Result
      attr_reader :audit, :content_item, :success

      def initialize(audit, content_item, success)
        @audit = audit
        @content_item = content_item
        @success = success
      end
    end

  private

    def clear_redirect_urls_if_not_redundant
      attributes["redirect_urls"] = "" unless ActiveModel::Type::Boolean.new.cast(attributes["redundant"])
    end

    def clear_similar_urls_if_not_similar
      attributes["similar_urls"] = "" unless ActiveModel::Type::Boolean.new.cast(attributes["similar"])
    end
  end
end
