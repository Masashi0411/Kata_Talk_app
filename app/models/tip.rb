# app/models/tip.rb
# == Schema Information
#  scheduled_date :date     # そのTIPの“日付”
#  content        :text     # ひとこと本文 など
#
# このモデルは、日付ベースで1日1TIPを想定（運用で1日複数が必要なら後述）
class Tip < ApplicationRecord
  # バリデーション（1日1TIPが前提ならuniqueを推奨）
  validates :scheduled_date, presence: true, uniqueness: true

  # よく使うクエリ
  scope :on,     ->(date) { where(scheduled_date: date) }
  scope :before, ->(date) { where("scheduled_date < ?", date) }
  scope :after,  ->(date) { where("scheduled_date > ?", date) }

  # 今日のTIP（明示的にタイムゾーンを使う）
  def self.today(date = Time.zone.today)
    on(date).first
  end

  # 指定TIPの前/次（存在しなければnil）
  def self.previous_of(tip)
    before(tip.scheduled_date).order(scheduled_date: :desc).first
  end

  def self.next_of(tip)
    after(tip.scheduled_date).order(scheduled_date: :asc).first
  end
end
