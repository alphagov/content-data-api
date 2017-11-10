module FilterHelper
  def filter_to_hidden_fields
    hidden_fields = params_to_filter.to_h.each_with_object([]) do |(key, value), fields|
      if value.is_a?(Array)
        value.each do |array_element|
          fields << hidden_field_tag("#{key}[]", array_element)
        end
      else
        fields << hidden_field_tag(key, value)
      end
    end

    hidden_fields.join.html_safe
  end
end
