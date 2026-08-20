require "test_helper"

class RailsDenPublicBoardsTest < ActionDispatch::IntegrationTest
  test "community homepage shows only enabled public categories" do
    RailsDen::Category.create!(
      title: "Visible Category",
      slug: "visible-category"
    )

    RailsDen::Category.create!(
      title: "Disabled Category",
      slug: "disabled-category",
      enabled: false
    )

    RailsDen::Category.create!(
      title: "Private Category",
      slug: "private-category",
      visibility: "private"
    )

    get "/rails_den"

    assert_response :success

    assert_includes response.body, "Visible Category"
    assert_not_includes response.body, "Disabled Category"
    assert_not_includes response.body, "Private Category"
  end

  test "community homepage shows only enabled public boards" do
    category = RailsDen::Category.create!(
      title: "General",
      slug: "general"
    )

    RailsDen::Board.create!(
      category: category,
      title: "Visible Board",
      slug: "visible-board"
    )

    RailsDen::Board.create!(
      category: category,
      title: "Disabled Board",
      slug: "disabled-board",
      enabled: false
    )

    RailsDen::Board.create!(
      category: category,
      title: "Private Board",
      slug: "private-board",
      visibility: "private"
    )

    get "/rails_den"

    assert_response :success

    assert_includes response.body, "Visible Board"
    assert_not_includes response.body, "Disabled Board"
    assert_not_includes response.body, "Private Board"
  end

  test "community homepage orders categories by position then id" do
    second = RailsDen::Category.create!(
      title: "Second Category",
      slug: "second-category",
      position: 2
    )

    first = RailsDen::Category.create!(
      title: "First Category",
      slug: "first-category",
      position: 1
    )

    also_first = RailsDen::Category.create!(
      title: "Also First Category",
      slug: "also-first-category",
      position: 1
    )

    get "/rails_den"

    assert_response :success

    first_index = response.body.index(first.title)
    also_first_index = response.body.index(also_first.title)
    second_index = response.body.index(second.title)

    assert first_index < also_first_index
    assert also_first_index < second_index
  end

  test "community homepage orders boards by position then id" do
    category = RailsDen::Category.create!(
      title: "General",
      slug: "general"
    )

    second = RailsDen::Board.create!(
      category: category,
      title: "Second Board",
      slug: "second-board",
      position: 2
    )

    first = RailsDen::Board.create!(
      category: category,
      title: "First Board",
      slug: "first-board",
      position: 1
    )

    also_first = RailsDen::Board.create!(
      category: category,
      title: "Also First Board",
      slug: "also-first-board",
      position: 1
    )

    get "/rails_den"

    assert_response :success

    first_index = response.body.index(first.title)
    also_first_index = response.body.index(also_first.title)
    second_index = response.body.index(second.title)

    assert first_index < also_first_index
    assert also_first_index < second_index
  end

  test "public board can be viewed" do
    category = RailsDen::Category.create!(
      title: "General",
      slug: "general"
    )

    board = RailsDen::Board.create!(
      category: category,
      title: "Announcements",
      slug: "announcements",
      description: "News and announcements"
    )

    get "/rails_den/boards/#{board.id}"

    assert_response :success
    assert_includes response.body, "General"
    assert_includes response.body, "Announcements"
    assert_includes response.body, "News and announcements"
    assert_includes response.body, "No topics yet"
  end

  test "disabled board cannot be viewed publicly" do
    category = RailsDen::Category.create!(
      title: "General",
      slug: "general"
    )

    board = RailsDen::Board.create!(
      category: category,
      title: "Disabled Board",
      slug: "disabled-board",
      enabled: false
    )

    get "/rails_den/boards/#{board.id}"

    assert_response :not_found
  end

  test "private board cannot be viewed publicly" do
    category = RailsDen::Category.create!(
      title: "General",
      slug: "general"
    )

    board = RailsDen::Board.create!(
      category: category,
      title: "Private Board",
      slug: "private-board",
      visibility: "private"
    )

    get "/rails_den/boards/#{board.id}"

    assert_response :not_found
  end

  test "board cannot be viewed when its category is disabled" do
    category = RailsDen::Category.create!(
      title: "Hidden Category",
      slug: "hidden-category",
      enabled: false
    )

    board = RailsDen::Board.create!(
      category: category,
      title: "Otherwise Public Board",
      slug: "otherwise-public-board"
    )

    get "/rails_den/boards/#{board.id}"

    assert_response :not_found
  end

  test "board cannot be viewed when its category is private" do
    category = RailsDen::Category.create!(
      title: "Private Category",
      slug: "private-category",
      visibility: "private"
    )

    board = RailsDen::Board.create!(
      category: category,
      title: "Otherwise Public Board",
      slug: "otherwise-public-board"
    )

    get "/rails_den/boards/#{board.id}"

    assert_response :not_found
  end
end