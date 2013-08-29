require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedKeyword < TongueTiedTests

  include Rack::Test::Methods

  # def test_user_has_required_phone_number
  #   assert_equal 0, User.count
  #   u = User.new(:uid => 'new_user_without_phone', :name => 'new user without phone')
  #   refute u.save
  #   u = User.new(:uid => 'new_user_without_phone', :name => 'new user without phone' :phone => '111')
  #   assert u.save
  #   assert_equal 1, User.co
  # end

  def test_user_has_name_field
    u = User.new(:uid => "test_name_field", :name => "test_name")
    assert_equal 'test_name', u.name
  end

  def test_user_can_be_found_or_created_from_provider
    expected_count = User.count + 1
    (1..2).each do
      u = User.first_or_create_from_provider('provider_uid', 'test_provider')
      assert u
      assert_equal u.provider, 'test_provider'          
    end
    assert_equal expected_count, User.count
  end

  def test_user_has_provider_and_defaults_to_app
    u = User.new(:uid => "test_user")
    assert u.save
    assert_equal "app", u.provider
  end

  def test_user_exists
    u = User.new(:uid => "test_user")
    assert u.save
  end

end