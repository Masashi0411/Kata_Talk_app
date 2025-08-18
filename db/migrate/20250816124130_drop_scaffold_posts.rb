# 目的: scaffoldで試作したpostsテーブルを削除し、MVPのスキーマで再作成するための整理
class DropScaffoldPosts < ActiveRecord::Migration[7.2]
  def up
    drop_table :posts, if_exists: true
  end

  def down
    create_table :posts do |t|
      t.string :title
      t.timestamps
    end
  end
end
