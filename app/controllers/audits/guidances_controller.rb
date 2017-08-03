module Audits
  class GuidancesController < ApplicationController
    def show
      @content = Support.get
    end
  end
end
