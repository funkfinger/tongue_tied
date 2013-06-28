#!/usr/bin/env ruby
require 'sinatra/base'
require 'twilio-ruby'
require 'data_mapper'
require 'haml'

db_connection_string = "postgres://#{ENV['DB_USER']}:#{ENV['DB_PASS']}@#{ENV['DB_HOST']}/#{ENV['DB_NAME']}"
DataMapper.setup(:default, db_connection_string)

# models...
class TextMessage
  include DataMapper::Resource
  property :id, Serial
  property :body, String
  timestamps :at
end

class TwilioRequest
  include DataMapper::Resource
  property :id, Serial
  property :request_data, Text
  timestamps :at
end

DataMapper.auto_migrate!

class TongueTiedApp < Sinatra::Base
  
  get '/' do
    "Tongue Tied App"
  end
  
  get '/test_form' do
    haml :test_form
  end

  get '/twilio/list' do
    @sms_list = TwilioRequest.all(:limit => 100)
    haml :twilio_list
  end
  
  get '/api/sms' do
    xml = Builder::XmlMarkup.new( :indent => 2 )
    xml.instruct!
    xml.Response{|r| r.Sms "text message response" }
    xml.target!
  end
  
  post '/api/sms' do
    content_type 'text/xml', :charset => 'utf-8'
    halt( 500, 'API error - missing SID') if params['SmsSid'].nil?
    if process_twilio_request( params )
      response_xml = ''
      xml = Builder::XmlMarkup.new( :indent => 2, :target => response_xml )
      xml.instruct!
      xml.Response{|r| r.Sms "text message response" }
      response_xml      
    else
      halt 500, 'API error - unable to save'
    end
      
  end
  
  
  def process_twilio_request( params )
    success = TwilioRequest.new( :request_data => params.to_s ).save
    return success
  end  
  
  
end
