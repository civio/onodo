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

  def related
    stories_created_from_self = self.stories.published
    other_viz_from_the_same_author = Visualization.published.where(author: self.author).where.not(id: self.id)
    other_stories_from_the_same_author = Story.published.where(author: self.author).where.not(id: stories_created_from_self.pluck(:id))

    result = stories_created_from_self +
             other_viz_from_the_same_author +
             other_stories_from_the_same_author

    result
  end
end
