class Api::StoriesController < ApiController

    def show
      @story = Story.find(params[:id])
    end

    def update
      @story = Story.find(params[:id])
      @story.update(story_params)
    end

  private

  def story_params
    params.require(:story).permit(:name, :description)
  end

end