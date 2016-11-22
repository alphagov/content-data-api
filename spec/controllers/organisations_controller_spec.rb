require 'rails_helper'

RSpec.describe OrganisationsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "returns JSON content type" do
      get :index
      expect(response.content_type).to eq('application/json')
    end


  end

end
