module Audits
  AllocationResult = Struct.new(:user, :count) do
    def success?
      count.nonzero?
    end

    def message
      if success?
        "#{count} #{'item'.pluralize(count)} assigned to #{user}"
      else
        'You did not select any content to be assigned'
      end
    end
  end
end
