class ChaptersController < ApplicationController
  before_action :set_chapter, only: [:edit, :update, :destroy]

  def new
    if current_user.nil?
      redirect_to new_user_session_path()
    end
    @story = Story.find(params[:story_id])
  end

  def edit
     @story = @chapter.story
  end

  def create
    @chapter = Chapter.new(chapter_params)
    @chapter.number = (@chapter.story.chapters.maximum(:number) || 0) + 1 if @chapter.number.nil? # TODO: concurrency scenarios

    @chapter.nodes = nodes_in(@chapter.relations)

    if @chapter.save
      redirect_to edit_story_path(@chapter.story), notice: 'Chapter was successfully created.'
    else
      flash[:alert] = @chapter.errors.full_messages.to_sentence
      render :new
    end
  end

  def update
    @chapter.update(chapter_params)

    @chapter.nodes = nodes_in(@chapter.relations)

    if @chapter.save
      redirect_to edit_story_path(@chapter.story), notice: 'Chapter was successfully updated.'
    else
      flash[:alert] = @chapter.errors.full_messages.to_sentence
      render :edit
    end
  end

  def update_image
    @chapter.update(chapter_params)
    redirect_to edit_chapter_path(@chapter)
  end

  def destroy
    @chapter.destroy
    redirect_to @chapter.story, notice: 'Chapter was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_chapter
    @chapter = Chapter.find(params[:id])
  end

  def nodes_in(relations)
    relations.flat_map{ |r|  [r.source, r.target] }.uniq
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def chapter_params
    params.require(:chapter).permit(:name, :description, :number, :story_id, :image, :image_cache, :remote_image_url, :remove_image, :relation_ids => [])
  end
end
