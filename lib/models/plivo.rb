class PlivoRequest
  
  include DataMapper::Resource
  property :id, Serial
  property :raw, Text, :required => true
  property :plivo_message_id, String
  property :to, String
  property :from, String
  property :text, String, :length => 160
  timestamps :at  

  def self.create_plivo_request(params)
    pr = PlivoRequest.new(
      :raw => params.to_s,
      :plivo_message_id => params['MessageUUID'],
      :to => params['To'],
      :from => params['From'],
      :text => params['Text']
    )
    return false unless pr.save
    return TextMessage.create_text_message({
      :body => pr[:text],
      :from_number => pr[:from],
      :to_number => pr[:to]
    })
  end

  # this seems like a weird place for this...
  def self.response_xml(message = "response", to, from)
    response_xml = ''
    xml = Builder::XmlMarkup.new(:indent => 2, :target => response_xml)
    xml.instruct!
    xml.Response{|r| r.Message({:src => from, :dst => to}, message)}
    response_xml
  end

# this doesn't work....
# curl -L -d "src=16023218695&dst=16023218695&text=BLH" https://auth_id:auth_token@api.plivo.com/v1/Message/


end
