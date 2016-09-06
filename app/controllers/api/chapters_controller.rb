class Api::ChaptersController < ApiController
  before_action :set_chapter, except: [:index]
  before_action :require_story_published!, only: [:show]

  def index
    story = Story.find(params[:story_id])
    render json: [] and return unless (story.published || (story.author == current_user) || (story.author == demo_user))
    @chapters = Chapter.where(story: story).order(:number)
  end

  def show
  end

  private

  def chapter_params
    params.require(:chapter).permit(:name, :description, :number, :story_id)
  end

  def set_chapter
    @chapter = Chapter.find(params[:id])
  end

  def require_story_published!
    render json: {} unless (@chapter.story.published || authorized)
  end

  def authorized
    (@chapter.story.author == current_user) || (@chapter.story.author == demo_user)
  end
end