Rails.application.routes.draw do
  # resources :posts
  # root "posts#index"
  root "pages#home"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  # 今日のひとこと（今日 or 最寄りTipを1件表示）
  # get  "today",    to: "phrases#today", as: :today_phrase
  get "today", to: "tips#today"

  get "practice", to: "posts#new"      # 練習ページ（投稿作成）
  get "drills",   to: "posts#index"    # みんなのひとこと（投稿一覧）
  get "dashboard", to: "pages#dashboard" # マイページ（仮）

  # タイムライン（当日 or 直近Tipに紐づく投稿一覧）
  # get "timeline", to: "posts#index",   as: :timeline

  # 投稿作成のみ許可（MVP）
  resources :posts, only: [ :create ]
end
