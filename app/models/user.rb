class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :visualizations, foreign_key: :author_id
  has_many :stories, foreign_key: :author_id

  validates :terms_of_service, acceptance: true
end
