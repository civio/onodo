class Api::NodesController < ApiController
  before_action :set_node, only: [:show, :update, :destroy]
  before_action :set_dataset, only: [:index, :types]
  before_action :check_node_ownership!, only: [:update, :destroy]
  before_action :check_node_access!, only: [:show]
  before_action :check_dataset_access!, only: [:index, :types]

  def index
    @nodes = @dataset.nodes.order(:name)
  end

  def types
    @node_types = @dataset.nodes
                    .select(:node_type)
                    .map(&:node_type)
                    .reject(&:blank?)
                    .uniq
  end

  def create
    @node = Node.create(node_params)
    render :show
  end

  def show
  end

  def update
    if params[:node][:image].nil? && params[:node][:remote_image_url].nil?
      params[:node][:remove_image] = 1
    end

    current_custom_fields = @node.custom_fields || {}
    @node.dataset.node_custom_fields.each do |cf|
      field = cf["name"]
      data = params[:node][field]
      next if data.nil?
      current_custom_fields = current_custom_fields.merge({cf["name"] => data})
    end
    params[:node][:custom_fields] = current_custom_fields

    @node.update(node_params)
    render :show
  end

  def destroy
    @node.destroy
    head :no_content
  end

  private

  def set_node
    @node = Node.find_by!(id: params[:id])
    @visualization = @node.visualization
  end

  def set_dataset
    @dataset = Dataset.find_by!(visualization_id: params[:visualization_id])
    @visualization = @dataset.visualization
  end

  def check_node_ownership!
    check_node_access!
    halt_with :show if published? && !authorized?
  end

  def check_node_access!
    halt_with json: {} unless published? || authorized?
  end

  def check_dataset_access!
    halt_with json: [] unless published? || authorized?
  end

  def authorized?
    (@visualization.try(:author) == current_user) || (@visualization.try(:author) == demo_user)
  end

  def published?
    @visualization.try(:published?)
  end

  def halt_with(response)
    render response and return
  end

  def node_params
    params.require(:node).permit(:name, :description, :visible, :node_type, :visualization_id, :dataset_id, :posx, :posy, :image, :image_cache, :remote_image_url, :remove_image, custom_fields: params[:node][:custom_fields].try(:keys))
  end
end