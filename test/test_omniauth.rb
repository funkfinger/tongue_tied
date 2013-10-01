require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedOmniauth < TongueTiedTests

  include Rack::Test::Methods

  def setup
    DataMapper.auto_migrate!
    @auth = YAML::load(SAMPLE_TWITTER_AUTH)
    Sinatra::Sessionography.session.clear
  end

  def test_sign_in_links_only_appears_if_not_signed_in
    get '/'
    assert_match /Sign\-In with Twitter/, last_response.body
    assert_match /Sign\-In with Facebook/, last_response.body
    get '/auth/blah/callback', {}, {'omniauth.auth' => @auth}
    get '/'
    assert_match /logged in as Fake User/, last_response.body
    refute_match /Sign-In with Twitter/, last_response.body
    refute_match /Sign-In with Facebook/, last_response.body
  end

  def test_user_raw_data_is_updated_each_time_they_log_in
    get '/auth/blah/callback', {}, {'omniauth.auth' => @auth}
    u = User.first(:uid => @auth.uid)
    assert_match @auth.info.image, u.raw, "#{@auth.info.image} not found in body"
    @auth.info.image = "new_image_string_blah_blah"
    get '/auth/blah/callback', {}, {'omniauth.auth' => @auth}
    u.reload
    assert_match "new_image_string_blah_blah", u.raw, "'new_image_string_blah_blah' not found in body"
  end

  def test_user_contains_raw_omniauth_data
    get '/auth/blah/callback', {}, {'omniauth.auth' => @auth}
    u = User.first(:uid => @auth.uid)
    assert_match @auth.info.image, u.raw, "#{@auth.info.image} not found in body"
  end

  def test_uid_is_set_in_session
    # refute current_session.session[:uid]
    get '/auth/blah/callback', {}, {'omniauth.auth' => @auth}
    follow_redirect!
    assert_match /logged in as/, last_response.body
    get '/users'
    assert_match /logged in as/, last_response.body
  end

  def test_multiple_sign_ins_doesnt_create_multiple_users
    expected_count = User.count + 1
    get '/auth/blah/callback', {}, {'omniauth.auth' => @auth}
    get '/auth/blah/callback', {}, {'omniauth.auth' => @auth}
    assert_equal expected_count, User.count
  end

  def test_throw_500_error_if_omniauth_auth_is_not_set
    get '/auth/blah/callback'
    assert_equal last_response.status, 500
  end

  def test_omniauth_callback_route_redirects
    get '/auth/blah/callback', {}, {'omniauth.auth' => @auth}
    follow_redirect!
    assert_equal "/", last_request.path
  end

  def test_user_is_created_from_omniauth
    expected_count = User.count + 1
    u = User.first_or_create_from_omniauth(@auth)
    assert u
    assert_equal u.uid, @auth[:uid]
    assert_equal u.provider, @auth[:provider]
    assert_equal u.name, @auth[:info][:name]
    assert_equal expected_count, User.count
  end

  def test_setup_loads_sample_auth_object
    assert_equal "1", @auth.uid
  end
  

end

SAMPLE_TWITTER_AUTH = <<-AUTH
--- !ruby/hash:OmniAuth::AuthHash
provider: twitter
uid: '1'
info: !ruby/hash:OmniAuth::AuthHash::InfoHash
  nickname: fake_screen_name
  name: Fake User
  location: Fake Location
  image: http://a0.twimg.com/profile_images/1097187958/Screen_shot_2010-08-06_at_2.06.30_PM_normal.png
  description: ! 'user description'
  urls: !ruby/hash:OmniAuth::AuthHash
    Website: http://t.co/fakeurl
    Twitter: https://twitter.com/fake_screen_name
credentials: !ruby/hash:OmniAuth::AuthHash
  token: fake_oauth_token
  secret: fake_oauth_secret
extra: !ruby/hash:OmniAuth::AuthHash
  access_token: !ruby/object:OAuth::AccessToken
    token: fake_oauth_token
    secret: fake_oauth_secret
    consumer: !ruby/object:OAuth::Consumer
      key: fake_oauth_consumer_key
      secret: fake_oauth_consumer_secret
      options:
        :signature_method: HMAC-SHA1
        :request_token_path: /oauth/request_token
        :authorize_path: /oauth/authenticate
        :access_token_path: /oauth/access_token
        :proxy: 
        :scheme: :header
        :http_method: :post
        :oauth_version: '1.0'
        :site: https://api.twitter.com
      http: !ruby/object:Net::HTTP
        address: api.twitter.com
        port: 443
        curr_http_version: '1.1'
        no_keepalive_server: false
        close_on_empty_response: false
        socket: 
        started: false
        open_timeout: 30
        read_timeout: 30
        continue_timeout: 
        debug_output: 
        use_ssl: true
        ssl_context: !ruby/object:OpenSSL::SSL::SSLContext
          cert: 
          key: 
          client_ca: 
          ca_file: 
          ca_path: 
          timeout: 
          verify_mode: 0
          verify_depth: 
          verify_callback: 
          options: -2147480577
          cert_store: 
          extra_chain_cert: 
          client_cert_cb: 
          tmp_dh_callback: 
          session_id_context: 
          session_get_cb: 
          session_new_cb: 
          session_remove_cb: 
          servername_cb: 
        enable_post_connection_check: true
        compression: 
        sspi_enabled: false
        ssl_version: 
        key: 
        cert: 
        ca_file: 
        ca_path: 
        cert_store: 
        ciphers: 
        verify_mode: 0
        verify_callback: 
        verify_depth: 
        ssl_timeout: 
      http_method: :post
      uri: !ruby/object:URI::HTTPS
        scheme: https
        user: 
        password: 
        host: api.twitter.com
        port: 443
        path: ''
        query: 
        opaque: 
        registry: 
        fragment: 
        parser: 
    params:
      :oauth_token: fake_oauth_token
      oauth_token: fake_oauth_token
      :oauth_token_secret: fake_oauth_secret
      oauth_token_secret: fake_oauth_secret
      :user_id: '1'
      user_id: '1'
      :screen_name: fake_screen_name
      screen_name: fake_screen_name
    response: !ruby/object:Net::HTTPOK
      http_version: '1.1'
      code: '200'
      message: OK
      header:
        cache-control:
        - no-cache, no-store, must-revalidate, pre-check=0, post-check=0
        content-length:
        - '1587'
        content-type:
        - application/json;charset=utf-8
        date:
        - Thu, 15 Aug 2013 16:49:21 GMT
        expires:
        - Tue, 31 Mar 1981 05:00:00 GMT
        last-modified:
        - Thu, 15 Aug 2013 16:49:21 GMT
        pragma:
        - no-cache
        server:
        - tfe
        set-cookie:
        - lang=en
        - guest_id=guest_id; Domain=.twitter.com; Path=/; Expires=Sat,
          15-Aug-2015 16:49:21 UTC
        status:
        - 200 OK
        strict-transport-security:
        - max-age=631138519
        x-access-level:
        - read
        x-frame-options:
        - SAMEORIGIN
        x-rate-limit-limit:
        - '15'
        x-rate-limit-remaining:
        - '8'
        x-rate-limit-reset:
        - '1376585561'
        x-transaction:
        - 62aef64c0eb12053
        connection:
        - close
      body: ! '{"id":1,"id_str":"1","name":"Fake User","screen_name":"fake_screen_name","location":"Phoenix,
        AZ","description":"user description","url":"http:\/\/t.co\/fakeurl","entities":{"url":{"urls":[{"url":"http:\/\/t.co\/fakeurl","expanded_url":"http:\/\/example.org","display_url":"example.org","indices":[0,22]}]},"description":{"urls":[]}},"protected":false,"followers_count":310,"friends_count":234,"listed_count":15,"created_at":"Fri
        Apr 06 20:32:32 +0000 2007","favourites_count":162,"utc_offset":-25200,"time_zone":"Arizona","geo_enabled":true,"verified":false,"statuses_count":1314,"lang":"en","contributors_enabled":false,"is_translator":false,"profile_background_color":"9AE4E8","profile_background_image_url":"http:\/\/a0.twimg.com\/profile_background_images\/1111\/twitter_bkgnd_neil_armstrong.jpg","profile_background_image_url_https":"https:\/\/si0.twimg.com\/profile_background_images\/1111\/twitter_bkgnd_neil_armstrong.jpg","profile_background_tile":true,"profile_image_url":"http:\/\/a0.twimg.com\/profile_images\/1097187958\/Screen_shot_2010-08-06_at_2.06.30_PM_normal.png","profile_image_url_https":"https:\/\/si0.twimg.com\/profile_images\/1097187958\/Screen_shot_2010-08-06_at_2.06.30_PM_normal.png","profile_link_color":"642626","profile_sidebar_border_color":"0E284E","profile_sidebar_fill_color":"F1F0F8","profile_text_color":"0E284E","profile_use_background_image":true,"default_profile":false,"default_profile_image":false,"following":false,"follow_request_sent":false,"notifications":false}'
      read: true
      socket: 
      body_exist: true
  raw_info: !ruby/hash:OmniAuth::AuthHash
    id: 1
    id_str: '1'
    name: Fake User
    screen_name: fake_screen_name
    location: Fake Location
    description: ! 'user description'
    url: http://t.co/fakeurl
    entities: !ruby/hash:OmniAuth::AuthHash
      url: !ruby/hash:OmniAuth::AuthHash
        urls:
        - !ruby/hash:OmniAuth::AuthHash
          url: http://t.co/fakeurl
          expanded_url: http://example.org
          display_url: example.org
          indices:
          - 0
          - 22
      description: !ruby/hash:OmniAuth::AuthHash
        urls: []
    protected: false
    followers_count: 310
    friends_count: 234
    listed_count: 15
    created_at: Fri Apr 06 20:32:32 +0000 2007
    favourites_count: 162
    utc_offset: -25200
    time_zone: Arizona
    geo_enabled: true
    verified: false
    statuses_count: 1314
    lang: en
    contributors_enabled: false
    is_translator: false
    profile_background_color: 9AE4E8
    profile_background_image_url: http://a0.twimg.com/profile_background_images/1111/twitter_bkgnd_neil_armstrong.jpg
    profile_background_image_url_https: https://si0.twimg.com/profile_background_images/1111/twitter_bkgnd_neil_armstrong.jpg
    profile_background_tile: true
    profile_image_url: http://a0.twimg.com/profile_images/1097187958/Screen_shot_2010-08-06_at_2.06.30_PM_normal.png
    profile_image_url_https: https://si0.twimg.com/profile_images/1097187958/Screen_shot_2010-08-06_at_2.06.30_PM_normal.png
    profile_link_color: '642626'
    profile_sidebar_border_color: 0E284E
    profile_sidebar_fill_color: F1F0F8
    profile_text_color: 0E284E
    profile_use_background_image: true
    default_profile: false
    default_profile_image: false
    following: false
    follow_request_sent: false
    notifications: false
AUTH

