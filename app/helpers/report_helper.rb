module ReportHelper
  def organisation_dimension_options_for_select(selected = nil)
    options = Dimensions::Organisation
                .pluck(:title, :content_id)
                .map { |title, content_id| [title.squish, content_id] }
                .sort_by { |title, _| title }

    options_for_select(options, selected)
  end
end
