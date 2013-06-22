#!/usr/bin/env ruby
require 'sinatra/base'
require 'sinatra/config_file'

class TongueTiedApp < Sinatra::Base
  register Sinatra::ConfigFile
  config_file './config.yml'
  
  get '/' do
    'Tongue Tied App'
  end
end