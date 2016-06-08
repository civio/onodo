class VisualizationsController < ApplicationController

  before_action :authenticate_user!, except: [:show]
  before_action :set_visualization, except: [:new, :create]
  before_action :require_visualization_ownership!, except: [:show, :new, :create]

  # GET /visualizations/:id
  def show
    # TODO: Implement related_items to get only related visualizations/stories
    @related_items  = Visualization.published
  end

  # GET /visualizations/:id/embed
  def embed
    render layout: 'embed'
  end

  # GET /visualizations/new
  def new
  end

  # POST /visualizations
  def create
    @visualization  = Visualization.new(visualization_params)

    if dataset_provided?
      importer = XlsxDatasetImporter.new(provided_dataset)
      dataset = importer.import
    end

    if importer && importer.error_message
      flash[:alert] = importer.error_message
      render :new and return
    end

    @visualization.dataset = dataset || Dataset.new
    @visualization.author = current_user

    unless @visualization.save
      flash[:alert] = @visualization.errors.full_messages.to_sentence
      render :new and return
    end

    redirect_to edit_visualization_path(@visualization), notice: "Your visualization was created!"
  end

  # GET /visualizations/:id/edit
  def edit
  end

  # GET /visualizations/:id/edit/info
  def edit_info
  end

  # PATCH /visualizations/:id/
  def update
    @visualization.update_attributes(edit_info_params)
    redirect_to visualization_path(@visualization)
  end

  # DELETE /visualizations/:id/
  def destroy
    @visualization.destroy
    redirect_to user_path(current_user), notice: "Your visualization has been deleted."
  end

  # POST /visualizations/:id/publish
  def publish
    @visualization.update_attributes(published: true)
    redirect_to visualization_path(@visualization)
  end
  
  # POST /visualizations/:id/unpublish
  def unpublish
    @visualization.update_attributes(:published => false)
    redirect_to visualization_path(@visualization)
  end

  private

  def set_visualization
    @visualization = Visualization.find(params[:id])
  end

  def require_visualization_ownership!
    redirect_to visualization_path(@visualization) if @visualization.author != current_user
  end

  def provided_dataset
    params[:visualization][:xlsx_file]
  end

  def dataset_provided?
    !provided_dataset.nil?
  end

  def visualization_params
    params.require(:visualization).permit(:name, :dataset)
  end

  def create_params
    params.require(:visualization).permit(:name, :dataset)
  end

  def edit_info_params
    params.require(:visualization).permit(:name, :description)
  end

end
