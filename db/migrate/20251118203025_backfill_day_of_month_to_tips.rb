# 既存の scheduled_date から day_of_month を埋めるバックフィル処理
# 将来の「日めくりTIP」取得ロジックへスムーズに移行するための準備段階
class BackfillDayOfMonthToTips < ActiveRecord::Migration[7.2]
  def up
    # 既存データのうち、scheduled_date が存在し
    # かつ day_of_month がまだ NULL のレコードだけを更新する
    #
    # Postgres の EXTRACT 関数で日（1〜31）だけ取り出してセットする
    execute <<~SQL
      UPDATE tips
        SET day_of_month = EXTRACT(DAY FROM scheduled_date)
      WHERE scheduled_date IS NOT NULL
        AND day_of_month IS NULL;
    SQL
  end

  def down
    # バックフィルの巻き戻し
    # day_of_month を NULL に戻すだけのシンプルな処理
    #
    # これにより "バックフィル前の状態" を再現できる
    execute <<~SQL
      UPDATE tips
        SET day_of_month = NULL;
    SQL
  end
end
