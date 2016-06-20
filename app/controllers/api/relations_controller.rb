class Api::RelationsController < ApiController

  before_action :set_relation, except: [:index, :types, :create]
  before_action :require_relation_ownership!, except: [:index, :types, :create, :show]

  def index
    dataset = Dataset.find_by(visualization_id: params[:visualization_id])
    @relations = dataset.relations
                     .includes(:source, :target)
                     .order('nodes.name', 'targets_relations.name')
  end

  def types
    dataset = Dataset.find_by(visualization_id: params[:visualization_id])
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
    render :show and return if @relation.visualization.author != current_user
  end

  def relation_params
    # order of :at, :from and :to is important, as the latter take precedence over the first
    params.require(:relation).permit(:source_id, :target_id, :relation_type, :direction, :at, :from, :to, :dataset_id)
  end

end