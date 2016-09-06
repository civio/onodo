class Api::StoriesController < ApiController
  before_action :set_story, except: [:create]
  before_action :require_story_published!, only: [:show]

  def show
  end

  def create
    @story = Story.create(story_params)
    render :show
  end

  private

  def story_params
    params.require(:story).permit(:name, :description, :published, :author_id, :visualization_id)
  end

  def set_story
    @story = Story.find(params[:id])
  end

  def require_story_published!
    render json: {} unless (@story.published || authorized)
  end

  def authorized
    (@story.author == current_user) || (@story.author == demo_user)
  end
end