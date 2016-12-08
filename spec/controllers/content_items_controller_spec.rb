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
        before do
          get :index, params: { organisation_id: organisation, order: :asc, sort: :public_updated_at }
        end

        it "uses order, sort, organisation_id, controller and action params" do
          expect(request.params.keys).to eq(%w(order sort organisation_id controller action))
        end

        it "uses asc as the order" do
          expect(request.params[:order]).to eq("asc")
        end

        it "sorts by a valid content item attribute" do
          content_item = build(:content_item)
          expect(content_item.attributes).to have_key(request.params[:sort])
        end

        it "returns content_items based on supplied params" do
          expect(assigns(:content_items).pluck(:id)).to eq([2, 1])
        end
      end

      context "in descending order" do
        before do
          get :index, params: { organisation_id: organisation, order: :desc, sort: :public_updated_at }
        end

        it "uses order, sort, organisation_id, controller and action params" do
          expect(request.params.keys).to eq(%w(order sort organisation_id controller action))
          expect(request.params[:order]).to eq("desc")
        end

        it "uses desc as the order" do
          expect(request.params[:order]).to eq("desc")
        end

        it "sorts by a valid content item attribute" do
          content_item = build(:content_item)
          expect(content_item.attributes).to have_key(request.params[:sort])
        end

        it "returns content_items based on supplied params" do
          expect(assigns(:content_items).pluck(:id)).to eq([1, 2])
        end
      end
    end
  end
end
