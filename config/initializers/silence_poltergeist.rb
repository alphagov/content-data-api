# Silence the Poltergeist version warning.
module Capybara
  module Poltergeist
    class Client
      def warn(*)
      end
    end
  end
end
