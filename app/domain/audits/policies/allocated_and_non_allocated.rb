module Audits
  module Policies
    class AllocatedAndNonAllocated
      def self.call(scope, allocated_to: nil) # rubocop:disable Lint/UnusedMethodArgument
        scope
      end
    end
  end
end
