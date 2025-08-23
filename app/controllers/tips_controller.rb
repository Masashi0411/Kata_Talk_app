# app/controllers/tips_controller.rb
class TipsController < ApplicationController
  def index
    order = params[:order]&.to_sym || :recent

    @tips =
      case order
      when :likes
        Tip.left_joins(:posts).group(:id).order("COUNT(posts.id) DESC")
      else
        Tip.order(scheduled_date: :desc)
      end
  end

  def show
    tip = Tip.find(params[:id])
    redirect_to drills_path(tip_id: tip.id)
  end

  # 今日/任意日表示（あなたが入れた新実装）
  def show_today
    base_date = _parse_date(params[:date]) || Time.zone.today
    @tip = Tip.on(base_date).first
    if @tip
      @prev_tip = Tip.previous_of(@tip)
      @next_tip = Tip.next_of(@tip)
    end
    render :today
  end

  private

  def _parse_date(raw)
    return if raw.blank?
    Date.parse(raw) rescue nil
  end
end
