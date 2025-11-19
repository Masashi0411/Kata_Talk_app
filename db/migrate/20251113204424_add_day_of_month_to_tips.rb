# 日めくりTIP対応の準備として day_of_month を追加するマイグレーション
class AddDayOfMonthToTips < ActiveRecord::Migration[7.2]
  def change
    # NULL許容（後続PRで NOT NULL / UNIQUE を付ける）
    add_column :tips, :day_of_month, :integer

    # 開発環境では通常インデックスでOK（本番ではCONCURRENTLYを別PR）
    add_index :tips, :day_of_month
  end
end
