class Story < ActiveRecord::Base
  include Searchable

  belongs_to :author, foreign_key: :author_id, class_name: User
  belongs_to :visualization
  has_many :chapters, -> { order(:number) }, dependent: :destroy

  scope :published, -> { where(published: true) }

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :author

  mount_uploader :image, StoryImageUploader
end
