# タイムライン＆投稿作成
class PostsController < ApplicationController
  # GET /timeline
  # - 基本は今日のTip、なければ直近Tipの投稿を新しい順で表示
  def index
    @tip =
      Tip.where(scheduled_date: Date.current).first ||
      Tip.order(scheduled_date: :desc).first

    @posts = @tip ? @tip.posts.order(created_at: :desc) : Post.none
  end

  def new; end     # 練習ページ

  # POST /posts
  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to timeline_path, notice: "投稿しました。"
    else
      # today での投稿失敗を想定して、同じコンテキストで再表示
      @tip = @post.tip
      flash.now[:alert] = @post.errors.full_messages.to_sentence
      render "phrases/today", status: :unprocessable_entity
    end
  end

  private

  # Strong Parameters（MVP 要件）
  def post_params
    params.require(:post).permit(:tip_id, :content, :display_nickname)
  end
end
