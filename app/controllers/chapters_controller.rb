class ChaptersController < ApplicationController

  before_action :authenticate_user!, except: [:show]
  before_action :set_chapter, except: [:new, :create]
  before_action :require_story_ownership!, except: [:show, :new, :create]
  before_action :require_story_published!, only: [:show]

  def new
    @story = Story.find(params[:story_id])
    @chapter = Chapter.new
  end

  def create
    @chapter = Chapter.new(chapter_params)
    @chapter.number = (@chapter.story.chapters.maximum(:number) || 0) + 1 if @chapter.number.nil? # TODO: concurrency scenarios

    @chapter.nodes = nodes_in(@chapter.relations)

    @story = @chapter.story

    if @chapter.save
      redirect_to edit_story_path(@story), notice: t('.success')
    else
      flash[:alert] = @chapter.errors.full_messages.to_sentence
      flash[:alert] = t('.image_error') if @chapter.errors.include? :image
      render json: { location: "#{request.fullpath}/new" } and return if xhr_request?
      render :new, location: new_story_chapter_path(@story)
    end
  end

  def edit
    @story = @chapter.story
  end

  def update
    @chapter.update(chapter_params)

    @chapter.nodes = nodes_in(@chapter.relations)

    if @chapter.save
      redirect_to edit_story_path(@chapter.story), notice: t('.success')
    else
      flash[:alert] = @chapter.errors.full_messages.to_sentence
      flash[:alert] = t('.image_error') if @chapter.errors.include? :image
      render json: { location: "#{request.fullpath}/edit" } and return if xhr_request?
      render :edit
    end
  end

  def update_image
    @chapter.update(chapter_params)
    redirect_to edit_chapter_path(@chapter)
  end

  def delete
    render layout: false
  end

  def destroy
    @chapter.destroy
    redirect_to edit_story_path(@chapter.story), notice: t('.success')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_chapter
    @chapter = Chapter.find(params[:id])
  end

  def nodes_in(relations)
    relations.flat_map{ |r|  [r.source, r.target] }.uniq
  end

  def require_story_ownership!
    redirect_to story_path(@chapter.story) unless authorized
  end

  def require_story_published!
    redirect_to root_path unless (@chapter.story.published || authorized)
  end

  def authorized
    (@chapter.story.author == current_user) || (@chapter.story.author == demo_user)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def chapter_params
    params.require(:chapter).permit(:name, :description, :number, :story_id, :image, :image_cache, :remote_image_url, :remove_image, :date_from, :date_to, :relation_ids => [])
  end
end
