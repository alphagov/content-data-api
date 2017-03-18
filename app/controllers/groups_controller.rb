class GroupsController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  def show
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      render :show, status: :created
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

private

  def group_params
    params.require(:group).permit(:slug, :name, :parent_group_slug, :group_type, content_item_ids: [])
  end
end
