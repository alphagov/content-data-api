require 'rails_helper'

RSpec.describe ContentItemsController, type: :controller do
  describe "GET #index" do
    let(:organisation) { create(:organisation_with_content_items) }

    before do
      get :index, params: { organisation_id: organisation }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "assigns list of content items" do
      expect(assigns(:content_items)).to eq(organisation.content_items)
    end

    it "renders the :index template" do
      expect(subject).to render_template(:index)
    end
  end
end
