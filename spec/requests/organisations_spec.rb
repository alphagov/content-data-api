require 'rails_helper'

RSpec.describe "Organisations", type: :request do
  describe "GET /organisations" do

    it "returns 200 when listing the organisations" do
      get organisations_path
      expect(response).to have_http_status(200)
    end

    it 'returns a JSON with the ids of the organisation' do
      Organisation.create!(slug: 'a_slug')

      get organisations_path
      expect(response.body).to eq([{slug: 'a_slug'}].to_json)
    end
  end
end
