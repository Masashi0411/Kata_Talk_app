# frozen_string_literal: true

# == Schema Information
# Table name: tips
#
#  id                    :bigint           not null, primary key
#  content               :text             not null         # DEPRECATED: 近く削除予定
#  scheduled_date        :date             not null, indexed (unique)
#  title                 :string           not null
#  description           :text             not null
#  practice_description  :text             not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# DB constraints:
#  - UNIQUE (scheduled_date)
#  - CHECK (char_length(title) <= 120)  # tips_title_length_check
#
# NOTE:
#  - 1日1TIPの運用前提。前後ナビ（previous/next）や「今日のTIP」取得を想定。
#  - posts が紐づくため、削除時は関連もまとめて削除する。
#  - 表示/入力は title, description, practice_description を中核として利用する。
class Tip < ApplicationRecord
  TITLE_MAX = 120

  # 関連
  has_many :posts, dependent: :destroy

  # バリデーション
  validates :scheduled_date, presence: true, uniqueness: true
  validates :title, presence: true, length: { maximum: TITLE_MAX }
  validates :description, presence: true
  validates :practice_description, presence: true
  # content は移行完了後にカラム自体を削除予定のため、ここではバリデーションしない
  # TODO: content カラム削除後、このコメントを除去する

  # スコープ（よく使うクエリ）
  scope :ordered, -> { order(scheduled_date: :asc) }
  scope :on,      ->(date) { where(scheduled_date: date) }
  scope :before,  ->(date) { where("scheduled_date < ?", date) }
  scope :after,   ->(date) { where("scheduled_date > ?", date) }

  # クラスメソッド
  #
  # @param [Date] date 取得したい日付（既定: Time.zone.today）
  # @return [Tip, nil]
  def self.today(date = Time.zone.today)
    on(date).first
  end

  # @param [Tip] tip 基準となるTIP
  # @return [Tip, nil] 直前のTIP（なければnil）
  def self.previous_of(tip)
    before(tip.scheduled_date).order(scheduled_date: :desc).first
  end

  # @param [Tip] tip 基準となるTIP
  # @return [Tip, nil] 直後のTIP（なければnil）
  def self.next_of(tip)
    after(tip.scheduled_date).order(scheduled_date: :asc).first
  end

  # インスタンスヘルパ（使い勝手向上）
  #
  # @return [Tip, nil]
  def previous
    self.class.previous_of(self)
  end

  # @return [Tip, nil]
  def next
    self.class.next_of(self)
  end
end
