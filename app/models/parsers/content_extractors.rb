module Parsers
  class ContentExtractors
    include Singleton

    def self.register(*args)
      instance.register(*args)
    end

    def self.for_schema(*args)
      instance.for_schema(*args)
    end

    def register(schema_name, parser)
      parsers[schema_name] = parser
    end

    def for_schema(schema_name)
      parsers[schema_name]
    end

  private

    def parsers
      @parsers ||= {}
    end
  end
  Dir[File.dirname(__FILE__) + '/*.rb'].each { |file| require file }
end
