class ChaptersController < ApplicationController
  before_action :set_chapter, only: [:edit, :update, :destroy]

  def new
    if current_user.nil?
      redirect_to new_user_session_path()
    end
    @story = Story.find(params[:story_id])
  end

  def edit
  end

  def create
    @chapter = Chapter.new(chapter_params)

    if @chapter.save
      redirect_to @chapter, notice: 'Chapter was successfully created.'
    else
      render :new
    end
  end

  def update
    if @chapter.update(chapter_params)
      redirect_to @chapter, notice: 'Chapter was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @chapter.destroy
    redirect_to chapters_url, notice: 'Chapter was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_chapter
    @chapter = Chapter.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def chapter_params
    params[:chapter]
  end
end
