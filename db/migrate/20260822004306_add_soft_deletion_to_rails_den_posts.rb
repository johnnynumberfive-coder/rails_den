class AddSoftDeletionToRailsDenPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :rails_den_posts, :deleted_at, :datetime

    add_reference :rails_den_posts,
                  :deleted_by,
                  polymorphic: true
  end
end