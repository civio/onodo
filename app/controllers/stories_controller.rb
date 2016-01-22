class StoriesController < ApplicationController

  # GET /stories/:id
  def show
    @story = Story.find(params[:id])
    @nodes = Node.where(dataset_id: @story.visualization.id)
    @relations = Relation.where(dataset_id: @story.visualization.id)
    @related_items = Visualization.all
  end

  # GET /stories/new
  def new
    if current_user.nil?
      redirect_to new_user_session_path()
    end
  end

  # POST /stories
  def create
  
  end

  # GET /stories/:id/edit
  def edit
    if current_user.nil?
      redirect_to new_user_session_path()
    else
      @story = Story.find(params[:id])
    end
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
