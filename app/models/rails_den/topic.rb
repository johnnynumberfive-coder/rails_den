module RailsDen
  class Topic < ApplicationRecord
    belongs_to :board
    belongs_to :author, polymorphic: true

    has_many :posts,
              dependent: :restrict_with_error
    validates :title, presence: true

    validates :slug,
              presence: true,
              uniqueness: { scope: :board_id },
              format: {
                with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
                message: "must contain only lowercase letters, numbers, and hyphens"
              }

    def self.model_name
      @model_name ||= ActiveModel::Name.new(
        self,
        nil,
        "RailsDen::Topic"
      )
    end
  end
end
