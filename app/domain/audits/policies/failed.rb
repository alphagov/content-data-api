module Audits
  module Policies
    class Failed
      def self.call(scope)
        scope.where(content_id: Audit.failing.select(:content_id))
      end
    end
  end
end
