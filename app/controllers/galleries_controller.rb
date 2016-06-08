class GalleriesController < ApplicationController

  before_action :authenticate_user!, except: [:show]
  before_action :set_gallery, only: [:edit, :update]
  before_action :require_gallery_editor_role!

  def edit
    @visualizations = Visualization.published
    @stories = Story.published
  end

  def update
    visualization_ids = gallery_params[:visualization_ids].reject(&:empty?).map{|id| id.to_i}
    story_ids = gallery_params[:story_ids].reject(&:empty?).map{|id| id.to_i}

    if @gallery.update(visualization_ids: visualization_ids, story_ids: story_ids)
      flash[:notice] =  'Gallery was successfully updated.'
    else
      flash[:alert] = @gallery.errors.full_messages.to_sentence
    end

    redirect_to gallery_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gallery
      @gallery = Gallery.instance
    end

    def require_gallery_editor_role!
      redirect_to gallery_path unless gallery_editor_role?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gallery_params
      params.require(:gallery).permit(:visualization_ids => [], :story_ids => [])
    end
end
