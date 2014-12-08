require_relative "../test_helper"

Capybara.app = Sinatra::Application

class CapybaraTest < MiniTest::Test
  include Capybara::DSL

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
