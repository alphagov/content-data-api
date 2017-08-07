module Audits
  module Policies
    class AuditedAndNotAudited
      def self.call(scope)
        scope
      end
    end
  end
end
