require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedKeyword < TongueTiedTests

  include Rack::Test::Methods

  def test_user_list_has_link
    u = User.first_or_create(:uid => "uid_with_phone_number", :phone => '1238234712934', :raw => 'whatever')
    get "/users"
    assert last_response.ok?
    assert_match "/user/#{u.id}", last_response.body
  end

  def test_user_has_raw_creation_data_if_created_by_provider
    u = User.first_or_create(:uid => "uid_with_phone_number", :phone => '1238234712934', :raw => 'whatever')
    assert_equal 'whatever', u.raw
  end

  def test_can_view_user
    u = User.first_or_create(:uid => "uid_with_phone_number", :phone => '1238234712934')
    get "/user/#{u.id}"
    assert last_response.ok?
    assert_match u.phone, last_response.body
  end

  def test_can_view_users_list
    u = User.first_or_create(:uid => "uid_with_phone_number", :phone => '111')
    get "/users"
    assert last_response.ok?
    assert_match u.uid, last_response.body
  end

  # def test_user_has_required_phone_number
  #   assert_equal 0, User.count
  #   u = User.new(:uid => 'new_user_without_phone', :name => 'new user without phone')
  #   refute u.save
  #   u = User.new(:uid => 'new_user_without_phone', :name => 'new user without phone' :phone => '111')
  #   assert u.save
  #   assert_equal 1, User.co
  # end

  def test_can_deactivate
    u = User.first_or_create(:uid => "uid_with_phone_number", :phone => '111')
    assert u.active, u.to_yaml
    assert u.deactivate
    u.reload
    refute u.active
  end

  def test_can_activate
    User.create(:uid => 'user_should_activate_with_text_message')
    u = User.first(:uid => 'user_should_activate_with_text_message')
    refute u.active
    assert u.activate
    u.reload
    assert u.active
  end

  def test_can_activate_phone_with_text
    User.create(:uid => 'user_should_activate_with_text_message')
    u = User.first(:uid => 'user_should_activate_with_text_message')
    refute u.active
    assert u.phone.nil?
    @t.text_messages.create(:body => "activate user_should_activate_with_text_message", :to_number => "1", :from_number => "999")
    u.reload
    assert u.active, u.to_yaml
    assert_equal '999', u.phone
  end

  def test_can_create_with_phone_activates_user
    User.create(:uid => "uid_with_phone_number", :phone => '111')
    u = User.first(:uid => 'uid_with_phone_number')
    assert u.active, u.to_yaml
  end

  def test_user_is_only_active_with_phone_number
    assert_equal 0, User.count
    User.create(:uid => "uid_without_phone_number")
    u = User.first(:uid => 'uid_without_phone_number')
    refute u.active
  end

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