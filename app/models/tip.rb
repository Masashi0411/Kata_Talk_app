class Tip < ApplicationRecord
  has_many :posts, dependent: :destroy

  validates :content, presence: true
  validates :scheduled_date, presence: true, uniqueness: true

  scope :today,  -> { where(scheduled_date: Date.current) }
  scope :recent, -> { order(scheduled_date: :desc) }
end
