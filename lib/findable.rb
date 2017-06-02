module Findable
  def find(identifier)
    instance = all.detect { |o| o.identifier === identifier }
    raise NotFoundError, "'#{identifier}' unrecognised" unless instance
    instance
  end

  class ::NotFoundError < StandardError; end
end
