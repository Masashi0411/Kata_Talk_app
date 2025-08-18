class CreatePostsForMvp < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :tip, null: false, foreign_key: true
      t.text :content, null: false
      t.string :display_nickname
      t.timestamps
    end

    # DBレベルでも150文字を担保（アプリ側と二重でガード）
    execute <<~SQL
      ALTER TABLE posts
      ADD CONSTRAINT posts_content_length_check
      CHECK (char_length(content) <= 150);
    SQL
  end
end
