require 'rails_helper'

RSpec.describe ContentItemsController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index, organisation_id: 1
      expect(response).to have_http_status(:success)
    end
  end
end
