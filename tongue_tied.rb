#!/usr/bin/env ruby
require 'sinatra/base'

class TongueTiedApp < Sinatra::Base

  get '/' do
    'Tongue Tied App'
  end
end