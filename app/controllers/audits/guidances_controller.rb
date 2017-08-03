module Audits
  class GuidancesController < ApplicationController
    def show
      @body = Govspeak::Document.new(File.read("doc/guidance.md")).to_html
    end
  end
end
