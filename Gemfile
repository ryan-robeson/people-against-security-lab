# A sample Gemfile
source "https://rubygems.org"

gem "sqlite3"
gem "sinatra"
gem "unicorn"
gem "rake"
gem "faker"
gem "rack-flash3", require: "rack/flash"
gem "sinatra-redirect-with-flash", require: "sinatra/redirect_with_flash"

group :development do
  gem "guard"
  gem "rack-livereload"
  gem "guard-livereload", require: false
  gem "guard-shotgun", require: false
  gem "guard-minitest", require: false
  gem "pry"
end

group :test do
  gem "minitest"
  gem "minitest-reporters"
  gem "rack-test", require: "rack/test"
  gem "capybara"
end
