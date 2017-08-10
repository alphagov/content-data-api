module Audits
  module Policies
    class Allocated
      def self.call(scope, allocated_to:)
        scope.joins(:allocation).where('allocations.uid = ?', allocated_to)
      end
    end
  end
end
