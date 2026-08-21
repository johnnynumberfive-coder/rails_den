require "test_helper"

module RailsDen
  class TopicTest < ActiveSupport::TestCase
    test "uses namespaced routing keys" do
      model_name = RailsDen::Topic.model_name

      assert_equal "rails_den_topics",
                   model_name.route_key

      assert_equal "rails_den_topic",
                   model_name.singular_route_key

      assert_equal "rails_den_topic",
                   model_name.param_key
    end

    test "valid topic" do
      board = create_board
      author = create_user

      topic = Topic.new(
        board: board,
        author: author,
        title: "Welcome to RailsDen",
        slug: "welcome-to-railsden"
      )

      assert topic.valid?
    end

    test "requires a board" do
      author = create_user

      topic = Topic.new(
        author: author,
        title: "Welcome",
        slug: "welcome"
      )

      assert_not topic.valid?
      assert_includes topic.errors[:board], "must exist"
    end

    test "requires an author" do
      board = create_board

      topic = Topic.new(
        board: board,
        title: "Welcome",
        slug: "welcome"
      )

      assert_not topic.valid?
      assert_includes topic.errors[:author], "must exist"
    end

    test "requires a title" do
      board = create_board
      author = create_user

      topic = Topic.new(
        board: board,
        author: author,
        slug: "welcome"
      )

      assert_not topic.valid?
      assert_includes topic.errors[:title], "can't be blank"
    end

    test "requires a slug" do
      board = create_board
      author = create_user

      topic = Topic.new(
        board: board,
        author: author,
        title: "Welcome"
      )

      assert_not topic.valid?
      assert_includes topic.errors[:slug], "can't be blank"
    end

    test "slug must use lowercase letters numbers and hyphens" do
      board = create_board
      author = create_user

      invalid_slugs = [
        "Welcome",
        "welcome topic",
        "welcome_topic",
        "-welcome",
        "welcome-"
      ]

      invalid_slugs.each do |slug|
        topic = Topic.new(
          board: board,
          author: author,
          title: "Welcome",
          slug: slug
        )

        assert_not topic.valid?, "#{slug.inspect} should be invalid"
      end
    end

    test "slug must be unique within a board" do
      board = create_board
      author = create_user

      Topic.create!(
        board: board,
        author: author,
        title: "First Welcome",
        slug: "welcome"
      )

      duplicate = Topic.new(
        board: board,
        author: author,
        title: "Second Welcome",
        slug: "welcome"
      )

      assert_not duplicate.valid?
      assert_includes duplicate.errors[:slug], "has already been taken"
    end

    test "same slug is allowed in different boards" do
      category = Category.create!(
        title: "General",
        slug: "general"
      )

      first_board = Board.create!(
        category: category,
        title: "Announcements",
        slug: "announcements"
      )

      second_board = Board.create!(
        category: category,
        title: "Support",
        slug: "support"
      )

      author = create_user

      Topic.create!(
        board: first_board,
        author: author,
        title: "Welcome",
        slug: "welcome"
      )

      topic = Topic.new(
        board: second_board,
        author: author,
        title: "Welcome",
        slug: "welcome"
      )

      assert topic.valid?
    end

    test "defaults to not pinned and not locked" do
      topic = Topic.create!(
        board: create_board,
        author: create_user,
        title: "Welcome",
        slug: "welcome"
      )

      assert_not topic.pinned?
      assert_not topic.locked?
    end

    private

    def create_board
      category = Category.create!(
        title: "General",
        slug: "general"
      )

      Board.create!(
        category: category,
        title: "Announcements",
        slug: "announcements"
      )
    end

    def create_user
      User.create!(
        email_address: "member@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
    end
  end
end