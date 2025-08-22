require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Basic 認証を全体に適用
    config.middleware.insert_after(::Rack::Runtime, ::Rack::Auth::Basic, "Restricted Area") do |u, p|
      # secure_compare を使ってタイミング攻撃を防ぐ
      ActiveSupport::SecurityUtils.secure_compare(u, ENV["BASIC_AUTH_USER"]) &
        ActiveSupport::SecurityUtils.secure_compare(p, ENV["BASIC_AUTH_PASSWORD"])
    end
  end
end
