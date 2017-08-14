module FilterHelper
  def filter_to_hidden_fields
    filter_params = params.except(:controller, :action)
    hidden_fields = filter_params.keys.map do |key|
      hidden_field_tag key, filter_params.dig(key)
    end

    hidden_fields.join.html_safe
  end
end
