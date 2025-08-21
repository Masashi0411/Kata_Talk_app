# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  helper_method :posts_enabled?   # ← 追加

  def new
    @tip  = find_target_tip
    @post = Post.new
  end

  def create
    @tip  = find_target_tip

    unless posts_enabled?
      flash[:alert] = "現在、投稿は一時停止中です。"
      return redirect_to practice_path(tip_id: @tip&.id)
    end

    @post = Post.new(post_params.merge(tip_id: @tip&.id))

    if @tip.nil?
      flash.now[:alert] = "投稿対象のひとことが見つかりません。"
      @post = Post.new
      return render :new, status: :unprocessable_entity
    end

    if @post.save
      session[:last_post_id] = @post.id
      redirect_to drills_path(tip_id: @tip.id, highlight_post_id: @post.id),
                  notice: "投稿しました。"
    else
      flash.now[:alert] = "投稿に失敗しました。入力内容をご確認ください。"
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @tip = find_target_tip
    @posts = @tip ? @tip.posts.order(created_at: :desc).limit(50).includes(:tip) : Post.none
    @highlight_post_id = params[:highlight_post_id].presence || session[:last_post_id]

    if @tip
      @prev_tip = Tip.where("scheduled_date < ?", @tip.scheduled_date).order(scheduled_date: :desc).first
      @next_tip = Tip.where("scheduled_date > ?", @tip.scheduled_date).order(scheduled_date: :asc).first
    end
  end

  private

  # ENVから安全に真偽値を解釈
  def posts_enabled?
    ActiveModel::Type::Boolean.new.cast(ENV["ENABLE_POSTS"])
  end

  # /drills と /practice の双方で使う “対象TIP決定（今日→直近→最古の保険）”
  def find_target_tip
    return Tip.find_by(id: params[:tip_id]) if params[:tip_id].present?

    Tip.find_by(scheduled_date: Date.current) ||
      Tip.where("scheduled_date <= ?", Date.current).order(scheduled_date: :desc).first ||
      Tip.order(scheduled_date: :asc).first
  end

  def post_params
    params.require(:post).permit(:content, :display_nickname)
  end
end
