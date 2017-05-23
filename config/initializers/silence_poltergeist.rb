# Silence the Poltergeist version warning.
module Capybara::Poltergeist
  class Client
    def warn(*)
    end
  end
end
