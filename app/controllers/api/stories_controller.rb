class Api::StoriesController < ApiController

  def show
    @story = Story.find(params[:id])
  end

  def create
    @story = Story.create(story_params)
    render :show
  end

  private

  def story_params
    params.require(:story).permit(:name, :description, :published, :author_id, :visualization_id)
  end

end