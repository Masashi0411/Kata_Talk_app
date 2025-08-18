class CreateTips < ActiveRecord::Migration[7.2]
  def change
    create_table :tips do |t|
      t.text :content, null: false
      t.date :scheduled_date, null: false
      t.timestamps
    end

    # 1日1TIP運用を想定（不要ならunique:falseに）
    add_index :tips, :scheduled_date, unique: true
  end
end
