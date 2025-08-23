# app/models/tip.rb
# == Schema Information
# Table name: tips
#
#  id             :bigint           not null, primary key
#  content        :text             not null
#  scheduled_date :date             not null, indexed (unique)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Tip < ApplicationRecord
  # Post との関連が無いと @tip.posts で落ちます
  has_many :posts, dependent: :destroy

  # 1日1TIP運用ならバリデーション推奨（DBはunique index済み）
  validates :scheduled_date, presence: true, uniqueness: true
  validates :content, presence: true

  # よく使うクエリ
  scope :on,     ->(date) { where(scheduled_date: date) }
  scope :before, ->(date) { where("scheduled_date < ?", date) }
  scope :after,  ->(date)  { where("scheduled_date > ?", date) }

  # 今日のTIP（Time.zone.today を使う前提）
  def self.today(date = Time.zone.today)
    on(date).first
  end

  # 指定TIPの前/次（存在しなければ nil）
  def self.previous_of(tip)
    before(tip.scheduled_date).order(scheduled_date: :desc).first
  end

  def self.next_of(tip)
    after(tip.scheduled_date).order(scheduled_date: :asc).first
  end
end
