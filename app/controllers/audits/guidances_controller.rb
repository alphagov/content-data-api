module Audits
  class GuidancesController < BaseController
    def show
      @content = Support.get
    end
  end
end
