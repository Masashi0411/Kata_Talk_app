set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
# bundle exec rails db:seed   # ← 一時的に追加
# Render のケースでどちらを使う？
# プロジェクトには bin/rails が存在しているので、
# bin/rails db:seed の方が Rails Way で推奨。