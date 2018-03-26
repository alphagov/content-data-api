class Api::OrganisationsController < Api::BaseController
    before_action :validate_params!
  
    def summary
      @metrics = query_series
      @metric_params = parsed_params

      render template: "api/metrics/summary"
    end
  
  private
  
    def query_series
      Facts::Metric
        .between(from, to)
        .by_organisation_id(organisation_id)
        .order('dimensions_dates.date asc')
        .group('dimensions_dates.date')
        .sum(metric)
    end
  
    delegate :from, :to, :metric, :organisation_id, to: :parsed_params
  
    def parsed_params
      @parsed_params ||= Api::Organisation.new(params.permit(:from, :to, :metric, :organisation_id, :format))
    end
  
    def validate_params!
      unless parsed_params.valid?
        error_response(
          "validation-error",
          title: "One or more parameters is invalid",
          invalid_params: parsed_params.errors.to_hash
        )
      end
    end
  end
  