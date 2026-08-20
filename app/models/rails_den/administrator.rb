module RailsDen
  class Administrator < ApplicationRecord
    belongs_to :user, polymorphic: true

    validates :user_id,
              uniqueness: {
                scope: :user_type
              }

    def self.model_name
      @model_name ||= ActiveModel::Name.new(
        self,
        nil,
        "RailsDen::Administrator"
      )
    end
  end
end
