require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedKeyword < TongueTiedTests

  include Rack::Test::Methods

  def test_user_exists
	u = User.new(:username => "test_user")
	assert u.save
  end

end