class Api::NodesController < ApiController
  
  def index
    dataset = Dataset.find_by(visualization_id: params[:visualization_id])
    @nodes = dataset.nodes.order(:name)
  end

  def types
    dataset = Dataset.find_by(visualization_id: params[:visualization_id])
    @node_types = dataset.nodes
                      .select(:node_type)
                      .map(&:node_type)
                      .reject(&:blank?)
                      .uniq
  end

  def show
    @node = Node.find(params[:id])
  end

  def create
    @node = Node.create(node_params)
    render :show
  end

  def update
    @node = Node.find(params[:id])

    if params[:node][:image].nil? && params[:node][:remote_image_url].nil?
      params[:node][:remove_image] = 1
    end

    @node.dataset.custom_fields.each do |cf|
      data = params[:node][cf]
      next if data.nil?
      current_custom_fields = @node.custom_fields || {}
      params[:node][:custom_fields] = current_custom_fields.merge({cf => data})
    end

    @node.update(node_params)
    render :show
  end

  def destroy
    Node.destroy(params[:id])
    head :no_content
  end

  private

  def node_params
    params.require(:node).permit(:name, :description, :visible, :node_type, :visualization_id, :dataset_id, :image, :image_cache, :remote_image_url, :remove_image, custom_fields: params[:node][:custom_fields].try(:keys))
  end

end