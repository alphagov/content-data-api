module Audits
  module Policies
    class Allocated
      def self.call(scope, allocated_to:)
        scope.joins(:allocation).where('allocations.user_id = ?', allocated_to)
      end
    end
  end
end
