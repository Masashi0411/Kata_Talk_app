# frozen_string_literal: true

class AddMetaColumnsToTips < ActiveRecord::Migration[7.2]
  TITLE_MAX = 120

  def up
    # 1) いったんNULL許容で追加（既存データがあっても落ちない）
    add_column :tips, :title, :string, comment: "TIPのタイトル"
    add_column :tips, :description, :text, comment: "TIPの背景/説明文"
    add_column :tips, :practice_description, :text, comment: "TIPの練習用シナリオ/説明文"

    # 2) 既存行を初期化（content を流用しつつ空欄は埋める）
    execute <<~SQL.squish
      UPDATE tips
      SET
        title = COALESCE(title, '（タイトル未設定）'),
        description = COALESCE(description, ''),
        practice_description = COALESCE(practice_description, '')
    SQL

    # 3) NOT NULL付与（以降は必須項目）
    change_column_null :tips, :title, false
    change_column_null :tips, :description, false
    change_column_null :tips, :practice_description, false

    # 4) タイトル長チェック（DB制約）
    execute <<~SQL.squish
      ALTER TABLE tips
      ADD CONSTRAINT tips_title_length_check
      CHECK (char_length(title) <= #{TITLE_MAX});
    SQL

    # 検索ニーズが出たら有効化
    # add_index :tips, :title
  end

  def down
    execute "ALTER TABLE tips DROP CONSTRAINT IF EXISTS tips_title_length_check"
    remove_column :tips, :practice_description
    remove_column :tips, :description
    remove_column :tips, :title
  end
end
