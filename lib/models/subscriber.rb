class Subscriber
  include DataMapper::Resource
  property :id, Serial
  property :from_number, String, :required => true
  # property :to_number, String, :required => true
  property :active, Boolean, :default => true
  timestamps :at

  # TODO - validate_uniqueness_of...
  
  # belongs_to :campaign
  belongs_to :quiz, :required => false
  belongs_to :telephony_account
  has n, :subscriber_messages
  has n, :quiz_question_responses

  def deactivate
  	self.active = false
  	self.save
  end

  def self.active_subscribers
    all(:active => true)
  end

  def self.unsubscribe(text_message)
  	Subscriber.all(:from_number => text_message.from_number).each do |sub| 
  		sub.deactivate
  	end
  end

end
