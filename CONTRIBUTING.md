## ✅ `CONTRIBUTING.md`

# Contributing Guide – KataTalk

このリポジトリへ貢献（開発・修正・レビュー）する際の基本ルールをまとめています。  
個人開発・チーム開発問わず、一貫した品質を保つことを目的とします。

---

## 🧭 ブランチ運用

- ブランチ形式：`<type>/<issue-number>-<short-desc>`
  - 例：`feature/54-devise-setup`
- `type` の種類：
  - `feature`：新機能追加
  - `fix`：バグ修正
  - `refactor`：リファクタリング
  - `chore`：依存更新・環境調整
  - `ci`：CI設定
  - `docs`：ドキュメント追加・修正
- **禁止**：mainブランチへ直接push／commit

---

## 📝 コミットメッセージ規約

- 形式：`<type>: <要約> #<issue-number>`
- 例：


feat: Deviseのインストールと初期設定 #54

* devise gem導入、install実行
* Userモデル作成、jaロケール追加
* development.rbにdefault_url_options追加


- ルール：
- 1コミット = 1意図
- 機能追加と整形・軽微修正は分ける
- 2行目以降は箇条書きで変更点を明示

---

## 📨 プルリクエスト（PR）

- PRタイトル：`<type>: <要約> #<issue-number>`
- PR本文は `.github/PULL_REQUEST_TEMPLATE.md` を使用
- PRは **Draft** で作成し、レビュー依頼時に「Ready for review」に変更
- マージ方式：**Squash and merge**（履歴を整理）

---

## 🧩 命名規則（要約）

| 対象 | 命名ルール | 例 |
|------|--------------|----|
| モデル | 単数キャメル | `User`, `Tip` |
| テーブル | 複数スネーク | `users`, `posts` |
| 外部キー | `<model>_id` | `user_id` |
| ファイル | スネーク | `user_service.rb` |
| i18nキー | ドット区切り | `ja.devise.failure.invalid` |

---

## 🧪 テスト

- フレームワーク：RSpec
- 実行：`docker compose exec web bundle exec rspec`
- FactoryBot 使用（`spec/factories`）
- describe命名：`#method_name`（インスタンス） / `.method_name`（クラス）

---

## ⚙️ 開発環境

- Ruby 3.3.6 / Rails 7.2.1 / PostgreSQL / Docker
- Node.js 20 / esbuild / Tailwind
- 起動：
```bash
docker compose up
````

* DB初期化：

  ```bash
  docker compose exec web bin/rails db:setup
  ```

---

## 🚫 注意事項

* mainブランチへの直接コミット禁止
* 機密情報（APIキー等）は `ENV` 経由で管理
* Lintエラー・RSpec失敗状態でのPR作成禁止
* 重要変更時はレビュワー（@maintainer）に相談

---

💬 質問や提案は Issue または Discussions に投稿してください。