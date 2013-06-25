#!/usr/bin/env ruby
require 'sinatra/base'
require 'twilio-ruby'
require 'data_mapper'

class TongueTiedApp < Sinatra::Base
  db_connection_string = "postgres://#{ENV['DB_USER']}:#{ENV['DB_PASS']}@#{ENV['DB_HOST']}/#{ENV['DB_NAME']}"
  DataMapper.setup(:default, db_connection_string)
  
  get '/' do
    "Tongue Tied App"
  end
end