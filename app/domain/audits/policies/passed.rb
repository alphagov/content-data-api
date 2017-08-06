module Audits
  module Policies
    class Passed
      def self.call(scope)
        scope.where(content_id: Audit.passing.select(:content_id))
      end
    end
  end
end
