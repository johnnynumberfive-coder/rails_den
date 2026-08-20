require "administrate/base_dashboard"

class RailsDen::CategoryDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    title: Field::String,
    slug: Field::String,
    description: Field::Text,
    position: Field::Number,
    enabled: Field::Boolean,
    visibility: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    title
    slug
    position
    enabled
    visibility
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    title
    slug
    description
    position
    enabled
    visibility
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    title
    slug
    description
    position
    enabled
    visibility
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(category)
    category.title
  end
end