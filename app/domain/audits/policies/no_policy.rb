module Audits
  module Policies
    class NoPolicy
      def self.call(scope, *)
        scope
      end
    end
  end
end
