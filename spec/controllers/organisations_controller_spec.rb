require 'rails_helper'

RSpec.describe OrganisationsController, type: :controller do
  describe 'GET #index' do
    let(:organisation) { create(:organisation) }

    before do
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @organisations' do
      expect(assigns(:organisations)).to eq([organisation])
    end

    it "renders the index template" do
      expect(response).to render_template("index")
    end
  end
end
