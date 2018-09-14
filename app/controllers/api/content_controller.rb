class Api::ContentController < ApplicationController
  def index
    @content = Reports::Content.retrieve(from: params[:from], to: params[:to])
    render json: { results: @content }.to_json
  end
end
