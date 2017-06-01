module ParamHelper
  def filter_params
    request
      .query_parameters
      .deep_symbolize_keys
  end
end
