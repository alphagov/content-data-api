module Audits
  module Policies
    class NonAllocated
      def self.call(scope, allocated_to: nil) # rubocop:disable Lint/UnusedMethodArgument
        scope.where.not(id: Allocation.select(:content_item_id))
      end
    end
  end
end
