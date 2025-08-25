# frozen_string_literal: true

# app/controllers/tips_controller.rb
#
# ユーザー向け TIP 一覧/参照用コントローラ
# - index: 並び替え（recent/likes）に対応
# - show: 既存のドリル画面へリダイレクト（tips#show は使わず drills#show 相当へ委譲）
# - show_today: 指定日（未指定なら今日）の TIP を表示し、前後ナビ用に隣接 TIP も取得
class TipsController < ApplicationController
  ORDER_OPTIONS = %i[recent likes].freeze

  def index
    @order = _order_param

    @tips =
      case @order
      when :likes
        # 投稿数の多い順（NULL 安全のため LEFT JOIN）。N+1 を避けるため includes は不要。
        Tip.left_joins(:posts)
           .select("tips.*, COUNT(posts.id) AS posts_count")
           .group(:id)
           .order("COUNT(posts.id) DESC")
      else
        # 既定: 日付の新しい順
        Tip.order(scheduled_date: :desc)
      end
  end

  def show
    tip = Tip.find(params[:id])
    # 旧実装互換: ドリル詳細（みんなのひとこと）へ委譲
    redirect_to drills_path(tip_id: tip.id)
  end

  # 今日/任意日表示
  # GET /tips/today?date=2025-08-26
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

  # 並び替えパラメータのサニタイズ
  # @return [Symbol] :recent or :likes
  def _order_param
    key = params[:order]&.to_sym
    return key if ORDER_OPTIONS.include?(key)
    :recent
  end

  # date パラメータを Date にパース（失敗時は nil）
  # @param [String] raw
  # @return [Date, nil]
  def _parse_date(raw)
    return if raw.blank?

    Date.parse(raw)
  rescue ArgumentError
    nil
  end
end
