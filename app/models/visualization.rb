class Visualization < ActiveRecord::Base
  belongs_to :author, foreign_key: :author_id, class_name: User
  has_one :dataset, dependent: :destroy
  has_many :stories, dependent: :destroy

  scope :published, -> { where(published: true) }

  validates :name, presence: true, uniqueness: true

  def nodes
    dataset.nodes
  end

  def relations
    dataset.relations
  end
end
