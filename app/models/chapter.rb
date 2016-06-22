class Chapter < ActiveRecord::Base
  belongs_to :story
  has_and_belongs_to_many :nodes
  has_and_belongs_to_many :relations

  validates :name, presence: true

  mount_uploader :image, ChapterImageUploader

  def date_from
    format read_attribute(:date_from)
  end

  def date_to
    format read_attribute(:date_to)
  end

  def format date
    date.strftime('%d/%m/%Y') if date
  end
end
