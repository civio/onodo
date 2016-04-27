class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :avatar, AvatarUploader

  has_many :visualizations, foreign_key: :author_id
  has_many :stories, foreign_key: :author_id

  validates :name, presence: true
  validates :terms_of_service, acceptance: true
end
