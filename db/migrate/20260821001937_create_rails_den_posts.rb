class CreateRailsDenPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :rails_den_posts do |t|
      t.references :topic, null: false, foreign_key: { to_table: :rails_den_topics }
      t.references :author, polymorphic: true, null: false
      t.text :body, null: false

      t.timestamps
    end
  end
end
