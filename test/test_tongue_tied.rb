require File.expand_path '../test_helper.rb', __FILE__

class TongueTied < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    TongueTiedApp
  end
  
  
  def test_root_website_ok
    get '/'
    assert last_response.ok?
  end
  
  def test_config_file_holds_value
    assert_equal 'bar', app.settings.foo
  end

  
end