# app/controllers/tips_controller.rb
class TipsController < ApplicationController
  def index
    # 並べ替えパラメータを解釈
    order = params[:order] || :recent

    @tips = case order.to_sym
    when :likes
              Tip.left_joins(:posts) # いいね実装がまだなら仮に投稿数順
                 .group(:id)
                 .order("COUNT(posts.id) DESC")
    else
              Tip.order(scheduled_date: :desc) # 新着順
    end
  end

  # 詳細ページは作らず、投稿一覧へ誘導
  def show
    tip = Tip.find(params[:id])
    redirect_to drills_path(tip_id: tip.id)
  end

  def today
    @tip = Tip.find_by(scheduled_date: Date.current)

    # TIPが無い場合はフォールバック
    @tip ||= Tip.where("scheduled_date <= ?", Date.current).order(scheduled_date: :desc).first

    # 前後TIP（ナビゲーション用）
    @prev_tip = Tip.where("scheduled_date < ?", Date.current).order(scheduled_date: :desc).first
    @next_tip = Tip.where("scheduled_date > ?", Date.current).order(scheduled_date: :asc).first
  end
end
