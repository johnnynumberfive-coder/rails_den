require "test_helper"

module RailsDen
  class PostTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end

    test "model_name preserves the namespaced model identity" do
      model_name = RailsDen::Post.model_name

      assert_instance_of ActiveModel::Name, model_name
      assert_equal "RailsDen::Post", model_name.name
    end

    test "belongs to topic" do
      association = RailsDen::Post.reflect_on_association(:topic)

      assert_not_nil association
      assert_equal :belongs_to, association.macro
    end

    test "belongs to author" do
      association = RailsDen::Post.reflect_on_association(:author)

      assert_not_nil association
      assert_equal :belongs_to, association.macro
    end

    test "validates presence of body" do
      record = RailsDen::Post.new(body: nil)

      record.validate

      assert record.errors.of_kind?(:body, :blank)
    end
  end
end