module FilterHelper
  def filter_to_hidden_fields(*fields_to_exclude)
    filter_params = params.except(:controller, :action).except(*fields_to_exclude)
    hidden_fields = filter_params.keys.map do |key|
      hidden_field_tag key, filter_params.dig(key)
    end

    hidden_fields.join.html_safe
  end
end
