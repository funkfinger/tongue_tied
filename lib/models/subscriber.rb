class Subscriber
  include DataMapper::Resource
  property :id, Serial
  property :from_number, String, :required => true
  property :active, Boolean, :default => true
  
  belongs_to :campaign
  # belongs_to :text_message
  # has n, :campaigns

  def deactivate
  	self.active = false
  	self.save
  end

  def self.unsubscribe(text_message)
  	Subscriber.all(:from_number => text_message.from_number).each do |sub| 
  		sub.deactivate if sub.campaign.to_number == text_message.to_number
  	end
  end

end
