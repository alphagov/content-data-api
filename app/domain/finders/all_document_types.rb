class Finders::AllDocumentTypes
  def self.run
    new.run
  end

  def run
    ActiveRecord::Base.connection
      .execute(query)
      .field_values("document_type")
      .reject { |dt| DocumentType::IGNORED_TYPES.include? dt }
      .map { |dt| DocumentType.new(id: dt, name: dt.humanize) }
  end

private

  def query
    <<-SQL
      WITH RECURSIVE temp AS (
        (SELECT document_type FROM dimensions_editions WHERE live ORDER BY document_type LIMIT 1)
          UNION ALL
         SELECT (SELECT document_type FROM dimensions_editions WHERE document_type > temp.document_type AND live ORDER BY document_type LIMIT 1)
         FROM temp
         WHERE temp.document_type IS NOT NULL
      )
      SELECT document_type FROM temp WHERE document_type IS NOT NULL;
    SQL
  end
end
