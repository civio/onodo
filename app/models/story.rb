class Story < ActiveRecord::Base
  belongs_to :author, foreign_key: :author_id, class_name: User

  belongs_to :visualization

  scope :published, -> { where(published: true) }

  validates :name, presence: true, uniqueness: true
end
