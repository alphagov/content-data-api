module Content
  class Parsers::MetadataParser
    include Singleton
    def initialize
      @parsers = [
        Parsers::Metadata::NumberOfPdfs,
        Parsers::Metadata::NumberOfWordFiles,
        Parsers::Metadata::Metadata,
        Parsers::Metadata::PrimaryOrganisation,
        Parsers::Metadata::ContentHash,
      ]
    end

    def self.parse(raw_json)
      instance.parse(raw_json)
    end

    def parse(raw_json)
      attributes = { raw_json: raw_json }
      parsers.each do |p|
        attributes.merge! p.parse raw_json
      end
      attributes
    end

  private

    attr_reader :parsers
  end
end
