require_relative "../test_helper"

class RoutesTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_index
    get '/'
    assert last_response.ok?
  end

  def test_get_register
    get '/register'
    assert last_response.ok?
  end

  def test_get_login
    get '/login'
    assert last_response.ok?
  end
end
