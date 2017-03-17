class GroupsController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  def show
    @group = Group.find(params[:id])
  end
end
