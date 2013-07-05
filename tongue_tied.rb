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
  property :raw, Text, :required => true
  property :SmsSid, String
  property :SmsMessageSid, String
  property :SmsStatus, String
  property :AccountSid, String
  property :From, String
  property :To, String
  property :Body, String
  property :SmsSid, String
  property :FromZip, String
  property :ToZip, String
  property :FromState, String
  property :ToState, String
  property :FromCity, String
  property :ToCity, String
  property :FromCountry, String
  property :ToCountry, String
  property :ApiVersion, String
  timestamps :at
end

TwilioRequest.all({:raw => nil}).destroy!
DataMapper.auto_upgrade!

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
  
  post '/api/twilio/sms' do
    content_type 'text/xml', :charset => 'utf-8'
    halt( 500, 'API error - missing SID') if params['SmsSid'].nil?
    if process_twilio_request( params )
      twilio_response_xml( "created" )
    else
      halt 500, 'API error - unable to save'
    end 
  end
  
  def limit_twilio_params( params )
    valid_keys = [:SmsSid, :SmsMessageSid, :SmsStatus, :AccountSid, :From, :To, 
    :Body, :SmsSid, :FromZip, :ToZip, :FromState, :ToState, :FromCity, 
    :ToCity, :FromCountry, :ToCountry, :ApiVersion]

    valid_keys = ["SmsSid", "SmsMessageSid", "SmsStatus", "AccountSid", "From", "To", 
    "Body", "SmsSid", "FromZip", "ToZip", "FromState", "ToState", "FromCity", 
    "ToCity", "FromCountry", "ToCountry", "ApiVersion"]

    params.slice!(*valid_keys)
    params
  end
  
  def twilio_response_xml( message = "response" )
    response_xml = ''
    xml = Builder::XmlMarkup.new( :indent => 2, :target => response_xml )
    xml.instruct!
    xml.Response{|r| r.Sms message }
    response_xml
  end
  
  def process_twilio_request( params )
    tr = TwilioRequest.new(limit_twilio_params(params).merge({ :raw => params.to_s }))
    return false unless success = tr.save
    return create_text_message({
      :body => tr[:Body]
    })
  end  
  
  def create_text_message(message)
    tm = TextMessage.new(message)
    return tm.save
  end
  
end


class Hash
  def slice(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end
  
  def slice!(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    omit = slice(*self.keys - keys)
    hash = slice(*keys)
    replace(hash)
    omit
  end
end


