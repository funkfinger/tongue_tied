
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
  
  def self.response_xml(message = "response")
    response_xml = ''
    xml = Builder::XmlMarkup.new(:indent => 2, :target => response_xml)
    xml.instruct!
    xml.Response{|r| r.Sms message }
    response_xml
  end
    
  def self.create_twilio_request(params)
    tr = self.new(limit_twilio_params(params).merge({ :raw => params.to_s }))
    return false unless tr.save
    return TextMessage.create_text_message({
      :body => tr[:Body],
      :number => tr[:From]
    })
  end  
  
  private
  
  def self.limit_twilio_params(params)
    valid_keys = ["SmsSid", "SmsMessageSid", "SmsStatus", "AccountSid", "From", "To", 
    "Body", "SmsSid", "FromZip", "ToZip", "FromState", "ToState", "FromCity", 
    "ToCity", "FromCountry", "ToCountry", "ApiVersion"]

    params.slice!(*valid_keys)
    params
  end
  

end
