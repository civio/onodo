class Visualization < ActiveRecord::Base
  include Searchable

  belongs_to :author, foreign_key: :author_id, class_name: User
  has_one :dataset, dependent: :destroy
  has_many :stories, dependent: :destroy

  scope :published, -> { where(published: true) }

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :author

  def self.next_id
    connection.select_value("SELECT nextval('visualizations_id_seq')").to_i
  end

  def nodes
    dataset.nodes.order(:name)
  end

  def relations
    dataset.relations.includes(:source, :target).order('nodes.name', 'targets_relations.name')
  end
end
