class CreateRailsDenTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :rails_den_topics do |t|
      t.references :board,
                   null: false,
                   foreign_key: { to_table: :rails_den_boards }

      t.references :author,
                   polymorphic: true,
                   null: false

      t.string :title, null: false
      t.string :slug, null: false
      t.boolean :pinned, null: false, default: false
      t.boolean :locked, null: false, default: false

      t.timestamps
    end

    add_index :rails_den_topics,
              [:board_id, :slug],
              unique: true
  end
end
