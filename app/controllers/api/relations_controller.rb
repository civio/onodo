class Api::RelationsController < ApiController
  before_action :set_relation, only: [:show, :update, :destroy]
  before_action :set_dataset, only: [:index, :types]
  before_action :check_relation_ownership!, only: [:update, :destroy]
  before_action :check_relation_access!, only: [:show]
  before_action :check_dataset_access!, only: [:index, :types]

  def index
    @relations = @dataset.relations
                   .includes(:source, :target)
                   .order('nodes.name', 'targets_relations.name')
  end

  def types
    @relation_types = @dataset.relations
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
    @relation = Relation.find_by!(id: params[:id])
    @visualization = @relation.visualization
  end

  def set_dataset
    @dataset = Dataset.find_by!(visualization_id: params[:visualization_id])
    @visualization = @dataset.visualization
  end

  def check_relation_ownership!
    check_relation_access!
    halt_with :show if published? && !authorized?
  end

  def check_relation_access!
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

  def relation_params
    params.require(:relation).permit(:source_id, :target_id, :relation_type, :direction, :at, :from, :to, :dataset_id, custom_fields: params[:relation][:custom_fields].try(:keys))
  end











end