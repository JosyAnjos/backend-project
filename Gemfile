source "https://rubygems.org"

ruby "3.3.1"

gem "rails", "~> 7.1.3", ">= 7.1.3.2"
gem "pg", "~> 1.5"
gem "puma", "~> 7.0"
gem "redis", "~> 5.0"
gem "bootsnap", require: false
gem 'sidekiq'
gem 'active_model_serializers', '~> 0.10.0'
gem 'devise'

group :development, :test do
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails"
  gem "debug", platforms: %i[mri windows]
  gem 'faker'
end

group :test do
  gem "shoulda-matchers", "~> 5.0"
end