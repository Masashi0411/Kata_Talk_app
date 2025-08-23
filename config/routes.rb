Rails.application.routes.draw do
  # resources :posts
  # root "posts#index"
  root "pages#home"

  # TIP一覧
  resources :tips, only: [ :index, :show ]

  # 今日のひとこと（今日 or 最寄りTipを1件表示）
  get "/today", to: "tips#show_today", as: :today
  get "drills",   to: "posts#index"    # みんなのひとこと（投稿一覧）
  get "dashboard", to: "pages#dashboard" # マイページ（仮）

  # ひとコマ練習ページ（投稿フォーム）
  get  "practice", to: "posts#new"
  post "practice", to: "posts#create"

  resources :drills, only: [ :index ]
  resources :posts, only: [ :new, :create ]
end
