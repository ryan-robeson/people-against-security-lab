ENV['RACK_ENV'] = 'test'
require "bundler"
Bundler.require(:default, :test)

require "minitest/autorun"

# Silence annoying message. Seemed to be introduced with Faker gem
I18n.enforce_available_locales = false

# Custom Backtrace filter
class BacktraceFilter < Minitest::ExtensibleBacktraceFilter
  def self.default_filter
    super()
    @default_filter.add_filter(/opt\/boxen/) #remove this line to see full trace
    @default_filter
  end
end

Minitest::Reporters.use!(Minitest::Reporters::ProgressReporter.new, ENV, BacktraceFilter.default_filter)

require_relative "../people_against_security"

# Add some convenience methods to the DB while testing.
class Db
  # Empty tables, but don't drop them
  def clean!
    @db.transaction do |db|
      db.execute("delete from users;")
    end
  end

  # Empty tables and call the seed method.
  def reset!
    clean!
    @db.seed
  end
end

def login!(email, password)
  page.driver.post("/login", { email: email, password: password })
  page.driver.browser.follow_redirect!
end
