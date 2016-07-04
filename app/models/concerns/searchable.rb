module Searchable
  extend ActiveSupport::Concern

  SEARCHABLE_FIELD = 'name'

  module ClassMethods
    def search(text)
      self.where("#{SEARCHABLE_FIELD} ILIKE :text", text: "%#{text}%")
    end
  end
end