module RailsDen
  class Board < ApplicationRecord
    belongs_to :category

    enum :visibility,
         {
           public: "public",
           private: "private"
         },
         prefix: true

    validates :title, presence: true

    validates :slug,
              presence: true,
              uniqueness: { scope: :category_id },
              format: {
                with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
                message: "must contain only lowercase letters, numbers, and hyphens"
              }

    validates :position,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: 0
              }

    scope :ordered, -> { order(:position, :id) }

    def self.model_name
      @model_name ||= ActiveModel::Name.new(
        self,
        nil,
        "RailsDen::Board"
      )
    end
  end
end
