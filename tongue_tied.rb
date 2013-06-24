#!/usr/bin/env ruby
require 'sinatra/base'
require 'sinatra/config_file'
require 'twilio-ruby'

class TongueTiedApp < Sinatra::Base
  register Sinatra::ConfigFile
  config_file './config.yml'
    
  get '/' do
    "Tongue Tied App #{ENV['TWILIO_ACCOUNT_SID']}"
  end
end