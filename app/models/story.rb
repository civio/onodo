class Story < ActiveRecord::Base
  include Searchable

  belongs_to :author, foreign_key: :author_id, class_name: User
  belongs_to :visualization
  has_many :chapters, -> { order(:number) }, dependent: :destroy

  scope :published, -> { where(published: true) }

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :author

  mount_uploader :image, StoryImageUploader

  def related
    viz_from_which_self_was_created = self.visualization
    other_viz_from_the_same_author = Visualization.published.where(author: self.author).where.not(id: viz_from_which_self_was_created.id)
    other_stories_from_the_same_author = Story.published.where(author: self.author).where.not(id: self.id)

    result = [viz_from_which_self_was_created] +
             other_viz_from_the_same_author +
             other_stories_from_the_same_author

    result
  end
end
