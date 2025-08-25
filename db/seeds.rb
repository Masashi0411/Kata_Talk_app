# db/seeds.rb
# frozen_string_literal: true

# TIP/POST 冪等シード（ローカル/本番共通）
# - Tip: scheduled_date を自然キーとして upsert（重複しない最短の空き日付を自動採番可）
# - Post: (tip_id, content) を自然キーとして upsert（DB側は150文字制限）
# - content カラムは移行中サポート（将来削除しても動くよう分岐）

require "set"

puts "[SEED] start (tips + posts)"

# ------------------------------------------------------------
# 投入データ
# ------------------------------------------------------------
tips_with_posts = [
  {
    title: "相手と同じものに気づいたら声をかける",
    description: "同じ持ち物をきっかけに会話を始めると、心の距離が縮まる。",
    practice_description: "隣の人が同じペンを使っていた時、最初の一言は？",
    content: "相手と同じものに気づいたら声をかける",
    posts: [
      { content: "それ、僕も愛用してます！", display_nickname: "たけ" },
      { content: "インクの色は何色派ですか？", display_nickname: "さっちゃん" },
      { content: "そのグリップ握りやすいですよね。", display_nickname: "ゲストA" }
    ]
  },
  {
    title: "同じ飲み物を選んだときに共感を伝える",
    description: "共通点を見つけて『同じですね』と伝えるだけで仲間意識が生まれる。",
    practice_description: "相手と同じカフェラテを選んだ時、何と言いますか？",
    content: "同じ飲み物を選んだときに共感を伝える",
    posts: [
      { content: "カフェラテ仲間ですね！", display_nickname: "マリ" },
      { content: "ホット派ですか？アイス派ですか？", display_nickname: "ケン" },
      { content: "僕も甘さ控えめで頼みました！", display_nickname: "ゲストB" }
    ]
  },
  {
    title: "笑顔を添えて相手を褒める",
    description: "小さな『ステキですね！』が会話を明るくする。",
    practice_description: "コンビニで新しい商品を持っている相手に一言。",
    content: "笑顔を添えて相手を褒める",
    posts: [
      { content: "それ美味しそうですね！", display_nickname: "ナオ" },
      { content: "限定品ですよね？気になります。", display_nickname: "ミホ" },
      { content: "僕も次に買ってみます！", display_nickname: "ゲストC" }
    ]
  },
  {
    title: "『楽しかったこと』を聞いてみる",
    description: "広い質問から相手が話しやすいテーマを見つける。",
    practice_description: "久しぶりに会った友人に聞く最初の一言は？",
    content: "『楽しかったこと』を聞いてみる",
    posts: [
      { content: "最近楽しかったことありますか？", display_nickname: "まさ" },
      { content: "どんな休日を過ごしました？", display_nickname: "リナ" },
      { content: "新しい趣味とか始めました？", display_nickname: "ゲストD" }
    ]
  },
  {
    title: "『もし〜だったら』で話を広げる",
    description: "仮定の質問で会話の行き詰まりを和らげる。",
    practice_description: "旅行の話で盛り上げる時、どんな聞き方をしますか？",
    content: "『もし〜だったら』で話を広げる",
    posts: [
      { content: "もし1週間休みが取れたらどこ行きたいですか？", display_nickname: "トモ" },
      { content: "もし海外に行けるならどの国ですか？", display_nickname: "アユ" },
      { content: "もし宝くじ当たったらどうします？", display_nickname: "ゲストE" }
    ]
  },
  {
    title: "姿勢や頷きで好印象を与える",
    description: "言葉以外の要素が会話の安心感を生む。",
    practice_description: "自己紹介で相手に好印象を持ってもらうために？",
    content: "姿勢や頷きで好印象を与える",
    posts: [
      { content: "相槌をしっかり打つと話しやすいですね。", display_nickname: "ユウ" },
      { content: "姿勢を正すだけで気持ちも変わります。", display_nickname: "マイ" },
      { content: "笑顔と頷き、意識しています。", display_nickname: "ゲストF" }
    ]
  },
  {
    title: "『なるほどですね』で共感する",
    description: "相手の話を受け止めて安心感を伝える。",
    practice_description: "相手が趣味の話をしているときの反応は？",
    content: "『なるほどですね』で共感する",
    posts: [
      { content: "なるほど！それ楽しそうですね。", display_nickname: "タカ" },
      { content: "へぇ〜、意外でした！", display_nickname: "ヒロ" },
      { content: "なるほど、そういう考え方もありますね。", display_nickname: "ゲストG" }
    ]
  },
  {
    title: "『次は何したい？』と未来を聞く",
    description: "過去の体験から未来の行動へと自然に会話をつなげる。",
    practice_description: "旅行の話題から次の計画を聞くには？",
    content: "『次は何したい？』と未来を聞く",
    posts: [
      { content: "次はどこに行きたいですか？", display_nickname: "カナ" },
      { content: "今度やってみたいことありますか？", display_nickname: "ジュン" },
      { content: "次は誰と一緒に行きたいですか？", display_nickname: "ゲストH" }
    ]
  },
  {
    title: "欠点を先に伝えて安心感を作る",
    description: "不安材料を先に示すと、信頼が生まれる。",
    practice_description: "自分の提案に弱点がある時、どのように伝えますか？",
    content: "欠点を先に伝えて安心感を作る",
    posts: [
      { content: "ちょっと時間はかかるかもしれませんが…", display_nickname: "シン" },
      { content: "まだ試作段階ですが、試してみます？", display_nickname: "アカネ" },
      { content: "弱点はここですが、改善できます。", display_nickname: "ゲストI" }
    ]
  },
  {
    title: "『楽しい方』を選ぶ",
    description: "迷ったときは楽しい方を選ぶと前向きな会話が広がる。",
    practice_description: "休日の過ごし方を提案する一言は？",
    content: "『楽しい方』を選ぶ",
    posts: [
      { content: "せっかくだし楽しい方を選びましょう！", display_nickname: "リョウ" },
      { content: "どっちがワクワクしますか？", display_nickname: "アミ" },
      { content: "楽しい方を優先してみませんか？", display_nickname: "ゲストJ" }
    ]
  }
]

# ------------------------------------------------------------
# ユーティリティ
# ------------------------------------------------------------
def next_available_date(start_date, used_dates)
  d = start_date
  loop do
    return d unless used_dates.include?(d)
    d += 1.day
  end
end

def tips_table_has_content?
  Tip.column_names.include?("content")
end

# ------------------------------------------------------------
# 本体
# ------------------------------------------------------------
ActiveRecord::Base.transaction do
  base_date  = Date.current
  used_dates = Tip.where.not(scheduled_date: nil).pluck(:scheduled_date).to_set

  tips_with_posts.each_with_index do |raw_attrs, idx|
    attrs = raw_attrs.dup
    post_rows = attrs.delete(:posts) || []

    scheduled = attrs[:scheduled_date]
    unless scheduled
      candidate = base_date + idx.days
      scheduled = next_available_date(candidate, used_dates)
      used_dates.add(scheduled)
    end

    tip = Tip.find_or_initialize_by(scheduled_date: scheduled)

    title   = attrs[:title].to_s
    desc    = attrs[:description].to_s
    practice= attrs[:practice_description].to_s
    content = attrs[:content].to_s

    assign_hash = {
      title:                title,
      description:          desc,
      practice_description: practice
    }
    assign_hash[:content] = content if tips_table_has_content?

    tip.assign_attributes(assign_hash)
    tip.save!

    post_rows.each do |p|
      body      = p[:content].to_s[0, 150]
      nickname  = p[:display_nickname].presence
      post = Post.find_or_initialize_by(tip_id: tip.id, content: body)
      post.display_nickname = nickname if nickname.present? || post.new_record?
      post.save!
    end
  end
end

puts "[SEED] done (tips + posts upserted)"
