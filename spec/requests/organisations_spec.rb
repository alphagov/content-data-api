require 'rails_helper'

RSpec.describe "Organisations", type: :request do
  describe "GET /organisations" do
    it "returns 200 when listing the organisations" do
      get organisations_path
      expect(response).to have_http_status(200)
    end
  end
end
