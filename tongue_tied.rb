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
  property :body, String, :required => true
  property :keyword, String
  timestamps :at
  
  before :save, :make_keyword
  
  def make_keyword
    self.body.match(/^\s*(\S*)/)
    self.keyword = $1
  end
  
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
  # self.all({:raw => nil}).destroy!
end

class BetwextRequest
  include DataMapper::Resource
  property :id, Serial
  property :raw, Text, :required => true
  property :message_id, String
  property :sender_number, String, :required => true
  property :recipient_number, String
  property :message, String, :required => true
  property :time_received, String
  property :keyword, String, :required => true
  timestamps :at
  has n, :betwext_winners
end

class BetwextWinner
  include DataMapper::Resource
  property :id, Serial
  property :betwext_list_id, Integer
  belongs_to :betwext_request  
end

class BetwextKeyword
  include DataMapper::Resource
  property :id, Serial
  property :keyword, String, :required => true
end

class PlivoRequest
  include DataMapper::Resource
  property :id, Serial
  property :raw, Text, :required => true
  property :plivo_message_id, String
  property :to, String
  property :from, String
  property :text, String
  timestamps :at  
end

# DataMapper.auto_migrate!
DataMapper.auto_upgrade!

class TongueTiedApp < Sinatra::Base
  
  get '/' do
    "Tongue Tied App"
  end
  
  get '/test_form' do
    haml :test_form
  end

  get '/api/plivo/sms/list' do
    @plivo_list = PlivoRequest.all(:limit => 100)
    haml :plivo_list
  end

  post '/api/plivo/sms' do
    pr = PlivoRequest.new(
      :raw => params.to_s,
      :plivo_message_id => params['MessageUUID'],
      :to => params['To'],
      :from => params['From'],
      :text => params['Text']
    )
    halt 500, 'failed to save' unless pr.save
    plivo_response_xml( "created", params['From'], params['To'] )
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

  post '/api/betwext/sms' do
    halt( 500, 'API error - no params' ) if params.nil?
    br_exists = BetwextRequest.first(:sender_number => params['sender_number'], :keyword => params['keyword'])
    halt( 200, 'exists') if br_exists
    br = BetwextRequest.new({
      :raw => params.to_s,
      :message_id => params['message_id'],
      :sender_number => params['sender_number'],
      :recipient_number => params['recipient_number'],
      :message => params['message'],
      :time_received => params['time_received'],
      :keyword => params['keyword']
    })
    halt( 500, 'API error - can\'t save request' ) if !br.save
    keyword = BetwextKeyword.new({ :keyword => params['keyword'] })
    halt( 500, 'API error - can\'t save keyword' ) if !keyword.save
    'created'
  end
  
  get '/api/betwext/list' do
    @betwext_list = BetwextRequest.all(:limit => 100)
    haml :betwext_list
  end
  
  get '/api/betwext/keyword_list' do
    @betwext_keyword_list = BetwextKeyword.all(:limit => 100)
    haml :betwext_keyword_list
  end
  
  get '/api/betwext/keyword/:keyword' do
    @betwext_entries = BetwextRequest.all( :keyword => params[:keyword] )
    haml :betwext_keyword_number_list
  end
  
  get '/api/betwext/add_to_betwext_list/:keyword/:list/:number' do
    halt( 500, 'Error posting to Betwext' ) unless post_to_betwext(params[:number], params[:list])
    br = BetwextRequest.first(:sender_number => params[:number], :keyword => params[:keyword])
    if br.betwext_winners.first(:betwext_list_id => params[:list]).nil?
      br.betwext_winners.new(:betwext_list_id => params[:list])
      halt( 500, 'Error creating list entry' ) unless br.save
    end
    redirect "/api/betwext/keyword/#{params[:keyword]}"
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
  
  def plivo_response_xml( message = "response", to, from )
    response_xml = ''
    xml = Builder::XmlMarkup.new( :indent => 2, :target => response_xml )
    xml.instruct!
    xml.Response{|r| r.Message({:src => from, :dst => to}, message)}
    response_xml    
  end
  
  def twilio_response_xml( message = "response" )
    response_xml = ''
    xml = Builder::XmlMarkup.new( :indent => 2, :target => response_xml )
    xml.instruct!
    xml.Response{|r| r.Sms message }
    content_type 'text/xml'
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
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    return res.code == "302" ? true : false
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


