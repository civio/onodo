class StoriesController < ApplicationController

  before_action :authenticate_user!, except: [:show]
  before_action :set_story, except: [:new, :create]
  before_action :require_story_ownership!, except: [:show, :new, :create, :duplicate]
  before_action :require_story_published!, only: [:show, :duplicate]

  # GET /stories/:id
  def show
    # TODO: Implement related_items to get only related visualizations/stories
    @related_items    = @story.related
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
      redirect_to edit_story_path(@story), notice: t('.success')
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
    redirect_to dashboard_path(), notice: t('.success')
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

  # POST /stories/:id/duplicate
  def duplicate
    copy = @story.deep_clone include: [:chapters], use_dictionary: true
    copy.name = t('.copy_of') + " " + copy.name
    copy.published = false
    copy.author = current_user
    if copy.save
      redirect_to edit_story_path(copy), notice: t('.success')
    else
      flash[:alert] = t('.failure')
      redirect_to request.referer || story_path(@story)
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_story
    @story = Story.find(params[:id])
  end

  def require_story_ownership!
    redirect_to story_path(@story) unless authorized
  end

  def require_story_published!
    redirect_to root_path unless (@story.published || authorized)
  end

  def authorized
    (@story.author == current_user) || (@story.author == demo_user)
  end

  def story_params
    params.require(:story).permit(:name, :visualization_id)
  end

  def edit_info_params
    params.require(:story).permit(:name, :description, :image, :image_cache, :remote_image_url, :remove_image)
  end
end
