module Audits
  class GuidancesController < ApplicationController
    layout "audits"

    def show
      @content = Support.get
    end
  end
end
