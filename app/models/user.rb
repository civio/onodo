class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :avatar, UserAvatarUploader

  has_many :visualizations, foreign_key: :author_id
  has_many :stories, foreign_key: :author_id

  validates :name, presence: true
  validates :terms_of_service, acceptance: true
end
