#!/usr/bin/env ruby
require 'sinatra/base'
require 'twilio-ruby'
require 'data_mapper'

db_connection_string = "postgres://#{ENV['DB_USER']}:#{ENV['DB_PASS']}@#{ENV['DB_HOST']}/#{ENV['DB_NAME']}"
DataMapper.setup(:default, db_connection_string)

# models...
class TextMessage
  include DataMapper::Resource
  property :id, Serial
  property :body, String
  timestamps :at
end

DataMapper.auto_migrate!

class TongueTiedApp < Sinatra::Base
  get '/' do
    "Tongue Tied App"
  end
  
  get '/api/sms' do
    xml = Builder::XmlMarkup.new( :indent => 2 )
    xml.instruct!
    xml.Response{|r| r.Sms "text message response" }
    xml.target!
  end
  
  post '/api/sms' do
    content_type 'text/xml', :charset => 'utf-8'
    response_xml = ''
    xml = Builder::XmlMarkup.new( :indent => 2, :target => response_xml )
    xml.instruct!
    xml.Response{|r| r.Sms = "text message response" }
    response_xml
  end
  
end