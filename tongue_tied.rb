#!/usr/bin/env ruby
require 'sinatra/base'
require 'sinatra/config_file'

class TongueTiedApp < Sinatra::Base

  get '/' do
    'Tongue Tied App'
  end
end