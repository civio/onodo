class Api::StoriesController < ApiController

    def show
      @story = Story.find(params[:id])
    end

    def update
      @story = Story.find(params[:id])
      @story.update(story_params)
      render :show
    end

  private

  def story_params
    params.require(:story).permit(:name, :description, :published, :author_id, :visualization_id)
  end

end