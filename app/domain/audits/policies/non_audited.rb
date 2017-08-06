module Audits
  module Policies
    class NonAudited
      def self.call(scope)
        scope.where.not(content_id: Audit.all.select(:content_id))
      end
    end
  end
end
