# config/application.rb
require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    config.load_defaults 7.2

    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "Tokyo"          # 表示はJST
    # DBはUTCのまま推奨（既定）: config.active_record.default_timezone = :utc


    # --- Basic 認証（本番のみ）。ENV 未設定ならミドルウェアを積まない ---
    if Rails.env.production?
      user = ENV["BASIC_AUTH_USERNAME"] || ENV["BASIC_AUTH_USER"]
      pass = ENV["BASIC_AUTH_PASSWORD"]

      if user.present? && pass.present?
        user_digest = ::Digest::SHA256.hexdigest(user)
        pass_digest = ::Digest::SHA256.hexdigest(pass)

        config.middleware.insert_after(::Rack::Runtime, ::Rack::Auth::Basic, "Restricted Area") do |u, p|
          ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(u.to_s), user_digest) &&
            ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(p.to_s), pass_digest)
        end # ← do ... end（ミドルウェアブロック）
      end   # ← if user.present? && pass.present?
    end     # ← if Rails.env.production?
    # -----------------------------------------------------------------------
  end       # ← class Application
end         # ← module Myapp
