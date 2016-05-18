class Api::ChaptersController < ApiController

  def index
    @chapters = Chapter.where(story_id: params[:story_id]).order(:number)
  end

  def show
    @chapter = Chapter.find(params[:id])
  end

  private

  def chapter_params
    params.require(:chapter).permit(:name, :description, :number, :story_id)
  end

end