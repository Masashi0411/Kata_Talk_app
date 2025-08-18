# app/controllers/tips_controller.rb
class TipsController < ApplicationController
  def today
    @tip = Tip.find_by(scheduled_date: Date.current)

    # TIPが無い場合はフォールバック
    @tip ||= Tip.where("scheduled_date <= ?", Date.current).order(scheduled_date: :desc).first

    # 前後TIP（ナビゲーション用）
    @prev_tip = Tip.where("scheduled_date < ?", Date.current).order(scheduled_date: :desc).first
    @next_tip = Tip.where("scheduled_date > ?", Date.current).order(scheduled_date: :asc).first
  end
end
