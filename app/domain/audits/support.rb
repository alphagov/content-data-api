module Audits
  class Support
    def self.get
      File.read("doc/guidance.md")
    end
  end
end
