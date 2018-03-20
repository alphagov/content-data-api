class Metadata::Parser
  include Singleton
  def initialize
    @parsers = [
      Metadata::Parsers::NumberOfPdfs,
      Metadata::Parsers::NumberOfWordFiles,
      Metadata::Parsers::Metadata,
      Metadata::Parsers::PrimaryOrganisation,
      Metadata::Parsers::ContentHash
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
