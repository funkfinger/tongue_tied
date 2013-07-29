class Subscriber
  include DataMapper::Resource
  property :id, Serial
  property :number, Text, :required => true
  property :active, Boolean, :default => true
  
  belongs_to :campaign
  # belongs_to :text_message
  # has n, :campaigns
end
