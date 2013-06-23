#!/usr/bin/env ruby
require 'sinatra/base'
require 'sinatra/config_file'
require 'twilio-ruby'

class TongueTiedApp < Sinatra::Base
  register Sinatra::ConfigFile
  config_file './config.yml'
  
  @twilio_client = Twilio::REST::Client.new 'AC50c36451e9ccffe77249b8ca05936b1a', 'cc69499e93d89489afa13bc3fd9a31da'
  
  get '/' do
    "Tongue Tied App #{ENV['TWILIO_ACCOUNT_SID']}"
  end
end