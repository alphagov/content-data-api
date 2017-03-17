require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  describe "GET #show" do
    it "assigns the requested group as @group" do
      group = create :group
      get :show, format: :json, params: { id: group.to_param }

      expect(assigns(:group)).to eq(group)
    end
  end
end
