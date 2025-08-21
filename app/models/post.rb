class Post < ApplicationRecord
  belongs_to :tip

  validates :content, presence: true, length: { maximum: 150 }
  validates :display_nickname, length: { maximum: 30 }, allow_blank: true

  # scope :recent, -> { order(created_at: :desc) }
end
