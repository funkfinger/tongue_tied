#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra/base'
require 'twilio-ruby'
require 'haml'
require 'omniauth'
require 'omniauth-twitter'
require 'omniauth-facebook'
require 'sinatra/flash'
require 'plivo'

# require 'rack-flash'

require_relative 'lib/models/init'
require_relative 'lib/routes/init'
require_relative 'lib/helpers/init'


class TongueTiedApp < Sinatra::Base

  set :public_folder, 'public'
  enable :sessions
  # use Rack::Session::Cookie
  register Sinatra::Flash
  # use Rack::Flash

  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_OAUTH_CONSUMER_KEY'], ENV['TWITTER_OAUTH_CONSUMER_SECRET']
    provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET']
  end
  
  get '/' do
    haml :index
    # <<-HTML
    # <div>#{flash[:notice]}</div>
    # <a href='/auth/twitter'>Sign in with Twitter</a>    
    # HTML
  end
  
  get '/test_form' do
    haml :test_form
  end
  
  get '/api/sms' do
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.Response{ |r| r.Sms "text message response" }
    xml.target!
  end  
  
  def post_to_betwext(num, list)

    uri = URI('http://broadcast.betwext.com/subscribers/create_subscriber')
    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data('number' => num, 'list' => list)
    req.add_field 'Host', 'broadcast.betwext.com'
    req.add_field 'Content-Length', '64'
    req.add_field 'Cache-Control', 'max-age=0'
    req.add_field 'Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    req.add_field 'Origin', 'http://broadcast.betwext.com'
    req.add_field 'User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.116 Safari/537.36'
    req.add_field 'Content-Type', 'application/x-www-form-urlencoded'
    req.add_field 'Referer', 'http://broadcast.betwext.com/subscribers/create_subscriber'
    req.add_field 'Accept-Encoding', 'gzip,deflate,sdch'
    req.add_field 'Accept-Language', 'en-US,en;q=0.8'
    req.add_field 'Cookie', ENV['BETWEXT_COOKIE']
    res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
    redirect = res.header['location'] 
    if redirect
      uri = URI(redirect)
      redirect_res = Net::HTTP.get_response(uri)
    end

    return res.code == "302" ? true : false
  end
  
end







