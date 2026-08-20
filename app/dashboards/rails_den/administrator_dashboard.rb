require "administrate/base_dashboard"

class RailsDen::AdministratorDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    user: Field::String,
    user_type: Field::String,
    user_id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    user
    created_at
    updated_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    user
    user_type
    user_id
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(administrator)
    administrator.user.to_s
  end
end