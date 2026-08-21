module RailsDen
  class Post < ApplicationRecord
    belongs_to :topic
    belongs_to :author, polymorphic: true
    validates :body, presence: true 

    def self.model_name
      @model_name ||= ActiveModel::Name.new(
        self,
        nil,
        "RailsDen::Post"
      )
    end  
  end
end
