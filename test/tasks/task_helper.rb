ENV['RACK_ENV'] = 'test'
require "bundler/setup"
require "minitest"
require "minitest/reporters"
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
