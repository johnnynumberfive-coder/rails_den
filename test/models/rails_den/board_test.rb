require "test_helper"

module RailsDen
  class BoardTest < ActiveSupport::TestCase
    test "uses namespaced routing keys" do
      model_name = RailsDen::Board.model_name

      assert_equal "rails_den_boards",
                   model_name.route_key

      assert_equal "rails_den_board",
                   model_name.singular_route_key

      assert_equal "rails_den_board",
                   model_name.param_key
    end

    test "valid board" do
      category = Category.create!(
        title: "General",
        slug: "general"
      )

      board = Board.new(
        category: category,
        title: "Announcements",
        slug: "announcements"
      )

      assert board.valid?
    end

    test "requires a category" do
      board = Board.new(
        title: "Announcements",
        slug: "announcements"
      )

      assert_not board.valid?
      assert_includes board.errors[:category], "must exist"
    end

    test "requires a title" do
      category = Category.create!(
        title: "General",
        slug: "general"
      )

      board = Board.new(
        category: category,
        slug: "announcements"
      )

      assert_not board.valid?
      assert_includes board.errors[:title], "can't be blank"
    end

    test "requires a slug" do
      category = Category.create!(
        title: "General",
        slug: "general"
      )

      board = Board.new(
        category: category,
        title: "Announcements"
      )

      assert_not board.valid?
      assert_includes board.errors[:slug], "can't be blank"
    end

    test "slug must use lowercase letters numbers and hyphens" do
      category = Category.create!(
        title: "General",
        slug: "general"
      )

      invalid_slugs = [
        "Announcements",
        "general discussion",
        "general_discussion",
        "-announcements",
        "announcements-"
      ]

      invalid_slugs.each do |slug|
        board = Board.new(
          category: category,
          title: "Announcements",
          slug: slug
        )

        assert_not board.valid?, "#{slug.inspect} should be invalid"
      end
    end

    test "slug must be unique within a category" do
      category = Category.create!(
        title: "General",
        slug: "general"
      )

      Board.create!(
        category: category,
        title: "First General Board",
        slug: "general"
      )

      duplicate = Board.new(
        category: category,
        title: "Second General Board",
        slug: "general"
      )

      assert_not duplicate.valid?
      assert_includes duplicate.errors[:slug], "has already been taken"
    end

    test "same slug is allowed in different categories" do
      first_category = Category.create!(
        title: "General",
        slug: "general"
      )

      second_category = Category.create!(
        title: "Support",
        slug: "support"
      )

      Board.create!(
        category: first_category,
        title: "Announcements",
        slug: "announcements"
      )

      board = Board.new(
        category: second_category,
        title: "Announcements",
        slug: "announcements"
      )

      assert board.valid?
    end

    test "position cannot be negative" do
      category = Category.create!(
        title: "General",
        slug: "general"
      )

      board = Board.new(
        category: category,
        title: "Announcements",
        slug: "announcements",
        position: -1
      )

      assert_not board.valid?
    end

    test "defaults to enabled and public" do
      category = Category.create!(
        title: "General",
        slug: "general"
      )

      board = Board.create!(
        category: category,
        title: "Announcements",
        slug: "announcements"
      )

      assert board.enabled?
      assert board.visibility_public?
      assert_equal 0, board.position
    end

    test "ordered sorts by position then id" do
      category = Category.create!(
        title: "General",
        slug: "general"
      )

      second = Board.create!(
        category: category,
        title: "Second",
        slug: "second",
        position: 2
      )

      first = Board.create!(
        category: category,
        title: "First",
        slug: "first",
        position: 1
      )

      also_first = Board.create!(
        category: category,
        title: "Also First",
        slug: "also-first",
        position: 1
      )

      assert_equal [first, also_first, second], Board.ordered.to_a
    end
  end
end