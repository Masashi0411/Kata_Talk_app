# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def index
    @tip = find_tip!
    @posts = @tip.posts.order(created_at: :desc).limit(50).includes(:tip)

    @highlight_post_id = params[:highlight_post_id].presence || session[:last_post_id]

    @prev_tip = Tip.where("scheduled_date < ?", @tip.scheduled_date).order(scheduled_date: :desc).first
    @next_tip = Tip.where("scheduled_date > ?", @tip.scheduled_date).order(scheduled_date: :asc).first
  end

  private

  # 今日のTIPが無ければ直近の公開済TIPを返す
  def find_tip!
    return Tip.find(params[:tip_id]) if params[:tip_id].present?

    Tip.find_by(scheduled_date: Date.current) ||
      Tip.where("scheduled_date <= ?", Date.current).order(scheduled_date: :desc).first ||
      Tip.order(scheduled_date: :asc).first # データ完全空の保険
  end
end
