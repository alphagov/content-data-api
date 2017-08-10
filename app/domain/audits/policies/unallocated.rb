module Audits
  module Policies
    class Unallocated
      def self.call(scope, allocated_to: nil) # rubocop:disable Lint/UnusedMethodArgument
        scope.left_joins(:allocation).where(allocations: { id: nil })
      end
    end
  end
end
