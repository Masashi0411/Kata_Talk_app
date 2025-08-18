# db/seeds.rb
# frozen_string_literal: true

# Tip/Post 初期データ投入（冪等版）
# - Tip.scheduled_date は既存と衝突しない最短の空き日付を採番
# - Post は (tip_id, content) をキーに冪等作成
# - schema 前提:
#   Tips:  content:text NOT NULL, scheduled_date:date NOT NULL (unique)
#   Posts:  tip_id:fk NOT NULL, content:text NOT NULL (<= 150 char check), display_nickname:string

require "set"

puts "Seeding tips and posts..."

ActiveRecord::Base.transaction do
  # ---- 設定 ---------------------------------------------------------------
  base_date = Date.current

  tip_contents = [
    "「同じ」を口に出して仲間意識を築く",
    "説明の前にラポールを築く",
    "相手から『違います』の拒否に備えない",
    "「楽しかったこと」を聞く",
    "大きな的から質問して絞り込む",
    "会話の目的を明確にして成果を出す"
  ]

  sample_posts = {
    "「同じ」を口に出して仲間意識を築く" => [
      "私もその映画好きです！同じですね。",
      "あ、そのアプリ使ってます！共感できます。",
      "同じ趣味の人に出会えて嬉しいです。"
    ],
    "説明の前にラポールを築く" => [
      "まずは最近のお仕事の話を聞かせてください。",
      "少し雑談してから本題に入ってもいいですか？",
      "お元気そうで安心しました！"
    ],
    "相手から『違います』の拒否に備えない" => [
      "そういう考え方もありますね。",
      "なるほど！そういう見方もできますね。",
      "確かにそういう意見も大事だと思います。"
    ],
    "「楽しかったこと」を聞く" => [
      "最近楽しかったことは何ですか？",
      "休日に楽しんだことはありますか？",
      "どんなことをしているときが一番楽しいですか？"
    ],
    "大きな的から質問して絞り込む" => [
      "休日はインドア派ですか？アウトドア派ですか？",
      "旅行は好きですか？国内と海外ならどちらですか？",
      "趣味はスポーツ系ですか？文化系ですか？"
    ],
    "会話の目的を明確にして成果を出す" => [
      "今日は次のイベントの進め方を決めたいです。",
      "この会話のゴールは、来週の役割分担を決めることです。",
      "目的は『お互いが納得する着地点を見つけること』です。"
    ]
  }
  # ------------------------------------------------------------------------

  # 既存の使用済み日付を取得（nil を除外）
  used_dates = Tip.where.not(scheduled_date: nil).pluck(:scheduled_date).to_set

  # 空いている最短日付を見つける
  def next_available_date(start_date, used_dates_local)
    d = start_date
    loop do
      return d unless used_dates_local.include?(d)
      d += 1.day
    end
  end

  created_or_kept_tips = []

  tip_contents.each_with_index do |content, idx|
    tip = Tip.find_or_initialize_by(content: content)

    if tip.scheduled_date.blank?
      candidate = base_date + idx.days
      assigned  = next_available_date(candidate, used_dates)
      tip.scheduled_date = assigned
      used_dates.add(assigned) # 同一トランザクション内の重複を防止
    end

    tip.save!
    created_or_kept_tips << tip
  end

  # Post を冪等投入（(tip_id, content) で一意扱い）
  created_or_kept_tips.each do |tip|
    (sample_posts[tip.content] || []).each do |content|
      post = Post.find_or_initialize_by(tip_id: tip.id, content: content)
      post.display_nickname ||= "ゲスト"
      post.save! unless post.persisted?
    end
  end
end

puts "Seeding completed!"
