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
    @visualizations = Visualization.where(author_id: current_user.id).page(params[:page]).per(8)
  end

  # POST /stories
  def create
    story_params              = {}
    story_params[:name]       = params[:story][:name]
    story_params[:author_id]  = current_user.id
    @story  = Story.new( story_params )
    #@story.visualization = Visualization.where(id: params[:story][:visualization])

    if @story.save
      redirect_to story_path( @story ), :notice => "Your story was created!"
    else
      render "new"
    end
  end

  # GET /stories/:id/edit
  def edit
    if current_user.nil?
      redirect_to new_user_session_path()
    else
      @story = Story.find(params[:id])
    end
  end

  # GET /stories/:id/edit/info
  def editinfo
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

  # POST /stories/:id/publish
  def publish
    @story = Story.find(params[:id])

    if @story.update_attributes(:published => true)
      redirect_to story_path( @story )
    else
      redirect_to edit_story_path( @story )
    end
  end
  
  # POST /stories/:id/unpublish
  def unpublish
    @story = Story.find(params[:id])

    if @story.update_attributes(:published => false)
      redirect_to story_path( @story )
    else
      redirect_to edit_story_path( @story )
    end
  end
end
