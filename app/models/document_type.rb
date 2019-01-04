class DocumentType
  include ActiveModel::Model
  include ActiveModel::Serialization

  IGNORED_TYPES = %w[redirect gone vanish unpublishing need].freeze

  attr_accessor :id, :name

  def initialize(id:, name:)
    @id = id
    @name = name
  end

  def self.find_all
    all_document_types = ActiveRecord::Base.connection
      .execute(distinct_document_types_sql)
      .field_values('document_type')

    document_types = all_document_types.reject { |t| IGNORED_TYPES.include? t }

    document_types.map do |document_type|
      new(id: document_type, name: document_type.humanize)
    end
  end

  def self.distinct_document_types_sql
    <<-SQL
      WITH RECURSIVE temp AS (
        (SELECT document_type FROM dimensions_editions WHERE latest ORDER BY document_type LIMIT 1)
        UNION ALL
        SELECT (SELECT document_type FROM dimensions_editions WHERE document_type > temp.document_type AND latest ORDER BY document_type LIMIT 1)
        FROM temp
        WHERE temp.document_type IS NOT NULL
      )
      SELECT document_type FROM temp WHERE document_type IS NOT NULL;
    SQL
  end

  private_class_method :distinct_document_types_sql
end
