# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  helper_method :posts_enabled?   # 投稿停止フラグをビューでも使えるように

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

  # A案：@tip が見つからない場合は最新の投稿一覧にフォールバックして表示
  def index
    @tip = find_target_tip

    if @tip
      @posts = @tip.posts
                   .order(created_at: :desc)
                   .limit(50)
                   .includes(:tip)
      @highlight_post_id = params[:highlight_post_id].presence || session[:last_post_id]

      @prev_tip = Tip.where("scheduled_date < ?", @tip.scheduled_date)
                     .order(scheduled_date: :desc)
                     .first
      @next_tip = Tip.where("scheduled_date > ?", @tip.scheduled_date)
                     .order(scheduled_date: :asc)
                     .first
      return
    end

    # ← ここに来たらフォールバック（@tip=nil）
    @posts = Post.order(created_at: :desc)
                 .limit(50)
                 .includes(:tip)
    @highlight_post_id = params[:highlight_post_id].presence || session[:last_post_id]
    flash.now[:notice] = "対象のひとことが見つからなかったため、最新の投稿を表示します。"
    render :index, status: :ok
  end

  private

  # ENV から安全に真偽値を解釈
  def posts_enabled?
    ActiveModel::Type::Boolean.new.cast(ENV["ENABLE_POSTS"])
  end

  # /drills と /practice 共通の “対象TIP決定”
  # - params[:tip_id] があればそれを最優先
  # - 無ければ「今日」→「過去直近」→「最古」の順でフォールバック
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
