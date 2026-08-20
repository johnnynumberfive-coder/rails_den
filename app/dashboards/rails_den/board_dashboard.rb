require "administrate/base_dashboard"

class RailsDen::BoardDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    category: Field::BelongsTo,
    title: Field::String,
    slug: Field::String,
    description: Field::Text,
    position: Field::Number,
    enabled: Field::Boolean,
    visibility: Field::String,
    icon: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    category
    title
    slug
    position
    enabled
    visibility
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    category
    title
    slug
    description
    position
    enabled
    visibility
    icon
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    category
    title
    slug
    description
    position
    enabled
    visibility
    icon
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(board)
    board.title
  end
end