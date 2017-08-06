module Audits
  module Policies
    class Audited
      def self.call(scope)
        scope.joins(:audit)
      end
    end
  end
end
