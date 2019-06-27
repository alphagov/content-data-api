class Streams::ParentChild::Parser
  PARSERS = [
    ::Streams::ParentChild::ParentChildLinksParser,
    ::Streams::ParentChild::ManualSectionManualParser,
    ::Streams::ParentChild::ManualSectionsParser
  ].freeze

  def get_parent_id(payload)
    parser = parsers[payload['document_type']]
    return nil if parser.nil?

    parser.get_parent_id(payload)
  end

  def get_children_ids(payload)
    parser = parsers[payload['document_type']]
    return nil if parser.nil?

    parser.get_children_ids(payload)
  end

  def initialize
    register_parsers
  end

private

  def register_parsers
    PARSERS.each(&method(:register_parser))
  end

  def register_parser(parser_class)
    parser_class::DOCUMENT_TYPES.each do |document_type|
      parsers[document_type] = parser_class
    end
  end

  def parsers
    @parsers ||= {}
  end
end
