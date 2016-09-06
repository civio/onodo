class Api::RelationsController < ApiController

  before_action :set_relation, except: [:index, :types, :create]
  before_action :require_relation_ownership!, except: [:index, :types, :create, :show]
  before_action :require_visualization_published!, only: [:show]

  def index
    dataset = Dataset.find_by(visualization_id: params[:visualization_id])
    render json: [] and return unless (dataset.visualization.published || (dataset.visualization.author == current_user) || (dataset.visualization.author == demo_user))
    @relations = dataset.relations
                     .includes(:source, :target)
                     .order('nodes.name', 'targets_relations.name')
  end

  def types
    dataset = Dataset.find_by(visualization_id: params[:visualization_id])
    render json: [] and return unless (dataset.visualization.published || (dataset.visualization.author == current_user) || (dataset.visualization.author == demo_user))
    @relation_types = dataset.relations
                 .select(:relation_type)
                 .map(&:relation_type)
                 .reject(&:blank?)
                 .uniq
  end

  def create
    @relation = Relation.create(relation_params)
    render :show
  end

  def show
  end

  def update
    current_custom_fields = @relation.custom_fields || {}
    @relation.dataset.relation_custom_fields.each do |cf|
      field = cf["name"]
      data = params[:relation][field]
      next if data.nil?
      current_custom_fields = current_custom_fields.merge({cf["name"] => data})
      next
    end
    params[:relation][:custom_fields] = current_custom_fields

    @relation.update(relation_params)
    render :show
  end

  def destroy
    @relation.destroy
    head :no_content
  end

  private

  def set_relation
    @relation = Relation.find(params[:id])
  end

  def require_relation_ownership!
    render :show and return unless authorized
  end

  def require_visualization_published!
    render json: {} unless (@relation.visualization.published || authorized)
  end

  def authorized
    (@relation.visualization.author == current_user) || (@relation.visualization.author == demo_user)
  end

  def relation_params
    params.require(:relation).permit(:source_id, :target_id, :relation_type, :direction, :at, :from, :to, :dataset_id, custom_fields: params[:relation][:custom_fields].try(:keys))
  end

end