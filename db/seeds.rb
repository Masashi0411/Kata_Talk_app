today = Date.current
tip = Tip.find_or_create_by!(scheduled_date: today) { |t| t.content = "そのペン、ジェットストリームですよね？ 私も愛用してます！" }
Post.find_or_create_by!(tip:, content: "書き心地いいですよね！")
