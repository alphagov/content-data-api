module GoogleAnalytics
  class GoogleTagManager
    def initialize(current_user)
      @current_user = current_user
    end

    def data_layer
      [{
        organisation: @current_user.organisation_slug,
      }]
    end
  end
end
