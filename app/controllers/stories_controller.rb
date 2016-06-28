class StoriesController < ApplicationController

  before_action :authenticate_user!, except: [:show]
  before_action :set_story, except: [:new, :create]
  before_action :require_story_ownership, except: [:show, :new, :create]

  # GET /stories/:id
  def show
    # TODO: Implement related_items to get only related visualizations/stories
    @related_items    = Visualization.published
    @visualization    = @story.visualization
  end

  # GET /stories/new
  def new
    @visualizations = Visualization.published.where(author: current_user).page(params[:page]).per(8)
  end

  # POST /stories
  def create
    @story  = Story.new(story_params)
    @story.author = current_user


    if @story.save
      redirect_to edit_story_path(@story), :notice => "Your story was created!"
    else
      flash[:alert] = @story.errors.full_messages.to_sentence
      render :new
    end
  end

  # GET /stories/:id/edit
  def edit
    @visualization = @story.visualization
    render json: { location: request.fullpath } if xhr_request?
  end

  # GET /stories/:id/edit/info
  def edit_info
  end
  
  # PATCH /stories/:id/
  def update
    @story.update_attributes(edit_info_params)
    render json: { location: "#{request.fullpath}/edit" } and return if xhr_request?
    redirect_to edit_story_path(@story)
  end

  # DELETE /stories/:id/
  def destroy
    @story.destroy
    redirect_to user_path(current_user), notice: "Your story has been deleted."
  end

  # POST /stories/:id/publish
  def publish
    if @story.update_attributes(:published => true)
      redirect_to story_path( @story )
    else
      redirect_to edit_story_path( @story )
    end
  end
  
  # POST /stories/:id/unpublish
  def unpublish
    if @story.update_attributes(:published => false)
      redirect_to story_path( @story )
    else
      redirect_to edit_story_path( @story )
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_story
    @story = Story.find(params[:id])
  end

  def require_story_ownership
    redirect_to story_path(@story) if @story.author != current_user
  end

  def story_params
    params.require(:story).permit(:name, :visualization_id)
  end

  def edit_info_params
    params.require(:story).permit(:name, :description, :image, :image_cache, :remote_image_url, :remove_image)
  end
end
