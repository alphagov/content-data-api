module Importers
  class TodosForTaxonomyProject
    attr_reader :errors, :completed

    def initialize(group_name, csv_parser)
      @name = group_name
      @csv_parser = csv_parser
      @completed = []
      @errors = []
    end

    def run
      TaxonomyTodo.transaction do
        @csv_parser.each_row do |row|
          content_item = ContentItem.find_by(content_id: row['content_id'])
          if content_item
            TaxonomyTodo.create(
              taxonomy_project: project,
              content_item: content_item
            )
            track_success row['content_id']
          else
            track_failure row['content_id']
          end
        end
      end
    end

  private

    def track_failure(id)
      @errors << id
    end

    def track_success(id)
      @completed << id
    end

    def project
      @_project ||= TaxonomyProject.create(name: @name)
    end
  end
end
