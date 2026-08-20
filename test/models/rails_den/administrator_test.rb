require "test_helper"

module RailsDen
  class AdministratorTest < ActiveSupport::TestCase
    test "uses namespaced routing keys" do
      model_name = RailsDen::Administrator.model_name

      assert_equal "rails_den_administrators",
                   model_name.route_key

      assert_equal "rails_den_administrator",
                   model_name.singular_route_key

      assert_equal "rails_den_administrator",
                   model_name.param_key
    end

    test "belongs to a host user polymorphically" do
      user = create_user

      administrator = RailsDen::Administrator.create!(
        user: user
      )

      assert_equal user, administrator.user
      assert_equal "User", administrator.user_type
      assert_equal user.id, administrator.user_id
    end

    test "a host user can only be an administrator once" do
      user = create_user

      RailsDen::Administrator.create!(
        user: user
      )

      duplicate = RailsDen::Administrator.new(
        user: user
      )

      assert_not duplicate.valid?
      assert_includes duplicate.errors[:user_id], "has already been taken"
    end

    test "different host users can both be administrators" do
      first_user = create_user("first@example.com")
      second_user = create_user("second@example.com")

      assert RailsDen::Administrator.create!(user: first_user)
      assert RailsDen::Administrator.create!(user: second_user)
    end

    private

    def create_user(email_address = "admin@example.com")
      User.create!(
        email_address: email_address,
        password: "password123",
        password_confirmation: "password123"
      )
    end
  end
end