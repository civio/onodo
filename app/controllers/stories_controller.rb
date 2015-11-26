class StoriesController < ApplicationController

  # GET /stories/:id
  def show
    @story = Story.find(params[:id])
  end

  # GET /stories/new
  def new
    @story = Story.new
  end

  # GET /stories/:id/edit
  def edit
    @story = Story.find(params[:id])
  end

  # PATCH /stories/:id/
  def update
    @story = Story.find(params[:id])
  end

  # DELETE /stories/:id/
  def destroy
    @story = Story.find(params[:id])
  end
end
