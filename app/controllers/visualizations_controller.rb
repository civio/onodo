class VisualizationsController < ApplicationController

  # GET /visualizations/:id
  def show
    @visualization = Visualization.find(params[:id])
    @nodes = Node.where(dataset_id: params[:id])
    @relations = Relation.where(dataset_id: params[:id])
    @related_items = Visualization.all
  end

  # GET /visualizations/new
  def new
    if current_user.nil?
      redirect_to new_user_session_path()
    end
  end

  # POST /visualizations
  def create
    @visualization = Visualization.new( create_params )
    @visualization.author_id = current_user.id; 
    #@visualization.name = params[:name]
    puts @visualization
    @visualization.save
    redirect_to visualization_path( @visualization )
  end

  # GET /visualizations/:id/edit
  def edit
    if current_user.nil?
      redirect_to new_user_session_path()
    else
      @visualization = Visualization.find(params[:id])
    end
  end

  # GET /visualizations/:id/edit/info
  def editinfo
    if current_user.nil?
      redirect_to new_user_session_path()
    else
      @visualization = Visualization.find(params[:id])
    end
  end

  # PATCH /visualizations/:id/
  def update
    @visualization = Visualization.find(params[:id])
    @visualization.update_attributes( edit_info_params )
    redirect_to visualization_path( @visualization )
  end

  # DELETE /visualizations/:id/
  def destroy
    @visualization = Visualization.find(params[:id])
    @visualization.destroy
    redirect_to user_path( current_user ), :flash => { :success => "Visualization destroyed" }
  end

  # POST /visualizations/:id/publish
  def publish
    @visualization = Visualization.find(params[:id])

    if @visualization.update_attributes(:published => true)
      redirect_to visualization_path( @visualization )
    else
      redirect_to edit_visualization_path( @visualization )
    end
  end
  
  # POST /visualizations/:id/unpublish
  def unpublish
    @visualization = Visualization.find(params[:id])

    if @visualization.update_attributes(:published => false)
      redirect_to visualization_path( @visualization )
    else
      redirect_to edit_visualization_path( @visualization )
    end
  end

  private

    # TODO: aqui deberíamos validar los parámetros que queremos recibir

    def create_params
      params.require(:visualization).permit(:name, :nodes, :relations)
    end

    def edit_info_params
      params.require(:visualization).permit(:name, :description)
    end

end
