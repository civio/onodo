class Api::ChaptersController < ApiController

  def index
    @chapters = Chapter.where(story_id: params[:story_id]).order(:number)
  end

  def show
    @chapter = Chapter.find(params[:id])
  end

end