class StoriesController < ApplicationController

  # GET /stories/:id
  def show
    @story = Story.find(params[:id])
  end
end
