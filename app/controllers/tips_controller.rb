# app/controllers/tips_controller.rb
class TipsController < ApplicationController
  # 今日 or 任意日（params[:date]）のTIPを出し、前後TIPリンクを出す
  def show_today
    base_date = _parse_date(params[:date]) || Time.zone.today

    # その日のTIPを取る（なければ “直近の過去→未来” の順でフォールバックしたい場合はコメント外す）
    @tip = Tip.on(base_date).first
    # フォールバックを入れたい場合（任意）：
    # @tip ||= Tip.before(base_date).order(scheduled_date: :desc).first
    # @tip ||= Tip.after(base_date).order(scheduled_date: :asc).first

    if @tip.present?
      @prev_tip = Tip.previous_of(@tip)
      @next_tip = Tip.next_of(@tip)
    end

    # ビュー名を today に合わせる（今のファイル構成を活かす）
    render :today
  end

  private

  # 不正な日付は nil にする
  def _parse_date(raw)
    return if raw.blank?
    Date.parse(raw) rescue nil
  end
end
