class Api::VisualizationsController < ApiController

  before_action :set_visualization_and_dataset
  before_action :require_visualization_ownership!, except: [:show]
  before_action :require_visualization_published!, only: [:show]

  def show
  end

  def update
    node_custom_fields     = params[:visualization][:node_custom_fields] || []
    relation_custom_fields = params[:visualization][:relation_custom_fields] || []
    @dataset.node_custom_fields     = node_custom_fields.map {|cf| clean_custom_field_argument(cf) }
    @dataset.relation_custom_fields = relation_custom_fields.map {|cf| clean_custom_field_argument(cf) }
    @dataset.save
    params[:visualization].except!(:node_custom_fields, :relation_custom_fields)
    @visualization.update(visualization_params)
    render :show
  end

  def network_analysis
    # Get list of selected metrics
    selected_metrics = params.map {|p| p[1]=='1' ? p[0] : nil }.compact

    # Calculate selected metrics
    results, metrics_names = NetworkAnalysis.new(@dataset).calculate_metrics(selected_metrics)

    # Create the new custom fields, if needed
    network_metrics = metrics_names.map do |metric_name|
      {
        "name" => metric_to_custom_field_name(metric_name),
        "type" => "number",
        "readonly" => "true",
        "format" => "0.00"
      }
    end
    @dataset.node_custom_fields = (@dataset.node_custom_fields + network_metrics).uniq
    @dataset.save!

    # Populate the custom fields with the generated values.
    # To make sure we delete potentially existing stale values, we don't iterate through the results,
    # we iterate through all the nodes, cleaning existing values as we go.
    # Note: careful when editing hstore values, see commits f6c23f6 and c3f6067
    #   http://stackoverflow.com/questions/20251296/how-can-i-update-a-data-records-value-with-ruby-on-rails-4-0-1-postgresql-hstor
    #   https://github.com/rails/rails/issues/6127
    @dataset.nodes.each do |node|
      node_metrics = results[node.id.to_s] || {}
      node_custom_fields = node.custom_fields
      metrics_names.each do |metric_name|
        custom_field_name = metric_to_custom_field_name(metric_name)
        node_custom_fields[custom_field_name] = node_metrics[metric_name]
      end
      node.custom_fields = node_custom_fields
      node.save!
    end
  end

  def demo_data
    source = Visualization.find(ENV['DEMO_DATA_ID'])
    target = @visualization

    head :bad_request and return if (target.author != demo_user)

    target.dataset = source.dataset.deep_clone include: [:nodes, relations: [:source, :target]], use_dictionary: true
    target.dataset.nodes.each{ |n| n.image = source.nodes.find_by(name: n.name).image }
    target.dataset.save

    head :no_content
  end

  def clear_custom_fields
    @dataset.node_custom_fields = []
    @dataset.relation_custom_fields = []
    @dataset.nodes.map{ |n| n.custom_fields = {} }
    @dataset.relations.map{ |r| r.custom_fields = {} }
    @dataset.save
    head :no_content
  end

  def clear_network_analysis
    @dataset.node_custom_fields = @dataset.node_custom_fields.reject{ |cf| cf['name'][0] == '_' }
    @dataset.nodes.map{ |n| n.custom_fields = n.custom_fields.reject{ |k,_| k[0] == '_' } }
    @dataset.save
    head :no_content
  end

  private

  def set_visualization_and_dataset
    @visualization = Visualization.find(params[:id])
    @dataset = @visualization.dataset
  end

  def require_visualization_ownership!
    render :show and return unless authorized
  end

  def require_visualization_published!
    render json: {} unless (@visualization.published || authorized)
  end

  def authorized
    (@visualization.author == current_user) || (@visualization.author == demo_user)
  end

  def visualization_params
    params.require(:visualization).permit(:name, :description, :published, :author_id, :parameters)
  end

  # TODO: We're using the metric name as the custom field name, with an underscore prefix to avoid
  # crashing with potential user-generated fields. Should review/discuss this.
  def metric_to_custom_field_name(metric_name)
    '_'+metric_name
  end

  def clean_custom_field_argument(cf)
    clean_field = {
      "name" => cf["name"].downcase.gsub(' ', '_'),
      "type" => ["string", "number", "boolean"].any?{ |t| t == cf["type"].downcase } ? cf["type"].downcase : "string",
    }

    # Deal with optional fields. We could populate them anyway, but we'd rather keep it clean.
    clean_field["readonly"] = (cf["readonly"].downcase=="true" ? "true" : "false") unless cf["readonly"].nil?
    clean_field["format"] = cf["format"] unless cf["format"].nil?

    clean_field
  end
end