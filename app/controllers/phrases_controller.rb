# # 今日のひとこと表示用
# class PhrasesController < ApplicationController
#   # GET /today
#   # - 今日の Tip があればそれ
#   # - 無ければ 未来の最も近い日付
#   # - それも無ければ 過去の最も近い日付
#   def today
#     @tip =
#       Tip.where(scheduled_date: Date.current).first ||
#       Tip.where("scheduled_date > ?", Date.current).order(:scheduled_date).first ||
#       Tip.order(scheduled_date: :desc).first

#     # 投稿フォーム用（@tip が無い時はフォームを出さない）
#     @post = @tip ? Post.new(tip: @tip) : nil
#   end
# end
