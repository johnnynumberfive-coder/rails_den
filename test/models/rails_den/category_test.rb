require "test_helper"

module RailsDen
  class CategoryTest < ActiveSupport::TestCase
    test "uses namespaced routing keys" do
      model_name = RailsDen::Category.model_name

      assert_equal "rails_den_categories",
                   model_name.route_key

      assert_equal "rails_den_category",
                   model_name.singular_route_key

      assert_equal "rails_den_category",
                   model_name.param_key
    end

    test "valid category" do
      category = Category.new(
        title: "General",
        slug: "general"
      )

      assert category.valid?
    end

    test "requires a title" do
      category = Category.new(slug: "general")

      assert_not category.valid?
      assert_includes category.errors[:title], "can't be blank"
    end

    test "requires a slug" do
      category = Category.new(title: "General")

      assert_not category.valid?
      assert_includes category.errors[:slug], "can't be blank"
    end

    test "slug must use lowercase letters numbers and hyphens" do
      invalid_slugs = [
        "General",
        "general discussion",
        "general_discussion",
        "-general",
        "general-"
      ]

      invalid_slugs.each do |slug|
        category = Category.new(
          title: "General",
          slug: slug
        )

        assert_not category.valid?, "#{slug.inspect} should be invalid"
      end
    end

    test "slug must be unique" do
      Category.create!(
        title: "General",
        slug: "general"
      )

      duplicate = Category.new(
        title: "Another General",
        slug: "general"
      )

      assert_not duplicate.valid?
      assert_includes duplicate.errors[:slug], "has already been taken"
    end

    test "position cannot be negative" do
      category = Category.new(
        title: "General",
        slug: "general",
        position: -1
      )

      assert_not category.valid?
    end

    test "defaults to enabled and public" do
      category = Category.create!(
        title: "General",
        slug: "general"
      )

      assert category.enabled?
      assert category.visibility_public?
      assert_equal 0, category.position
    end

    test "ordered sorts by position then id" do
      second = Category.create!(
        title: "Second",
        slug: "second",
        position: 2
      )

      first = Category.create!(
        title: "First",
        slug: "first",
        position: 1
      )

      also_first = Category.create!(
        title: "Also First",
        slug: "also-first",
        position: 1
      )

      assert_equal [first, also_first, second], Category.ordered.to_a
    end
  end
end