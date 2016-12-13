require 'rails_helper'

RSpec.describe ContentItemsController, type: :controller do
  describe "GET #index" do
    context "find by organisation" do
      let(:organisation) { create(:organisation_with_content_items, content_items_count: 2) }

      before do
        get :index, params: { organisation_id: organisation }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns current organisation" do
        expect(assigns(:organisation)).to eq(organisation)
      end

      it "assigns list of content items" do
        expect(assigns(:content_items)).to eq(organisation.content_items)
      end

      it "renders the :index template" do
        expect(subject).to render_template(:index)
      end
    end

    context "sorts with parameters" do
      let(:content_items) do
        [
          build(:content_item, id: 1, public_updated_at: Time.parse("2016-12-09")),
          build(:content_item, id: 2, public_updated_at: Time.parse("2015-12-09"))
        ]
      end
      let(:organisation) { create(:organisation, content_items: content_items) }

      context "in ascending order" do
        it "returns content_items based on supplied params" do
          get :index, params: { organisation_id: organisation, order: :asc, sort: :public_updated_at }

          expect(assigns(:content_items).pluck(:id)).to match_array([2, 1])
        end
      end

      context "in descending order" do
      end

      it "returns content_items based on supplied params" do
        get :index, params: { organisation_id: organisation, order: :desc, sort: :public_updated_at }

        expect(assigns(:content_items).pluck(:id)).to match_array([1, 2])
      end
    end
  end
end
