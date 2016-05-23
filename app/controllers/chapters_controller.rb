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

    nodes_ids = @chapter.relations.flat_map{ |r|  [r.source_id, r.target_id] }.uniq
    @chapter.nodes = Node.find(nodes_ids)

    if @chapter.save
      redirect_to edit_story_path(@chapter.story), notice: 'Chapter was successfully created.'
    else
      render :new
    end
  end

  def update
    if @chapter.update(chapter_params)
      redirect_to edit_story_path(@chapter.story), notice: 'Chapter was successfully updated.'
    else
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

  # Never trust parameters from the scary internet, only allow the white list through.
  def chapter_params
    params.require(:chapter).permit(:name, :description, :number, :story_id, :image, :image_cache, :remote_image_url, :remove_image, :relation_ids => [])
  end
end
