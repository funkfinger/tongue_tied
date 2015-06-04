require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedOutgoingMessage < TongueTiedTests

  include Rack::Test::Methods

  def test_class_exists
    assert OutgoingMessage
  end

end