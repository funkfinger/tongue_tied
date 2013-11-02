class TelephonyAccount
  include DataMapper::Resource
  property :id, Serial
  property :number, String, :required => true
  property :provider, String, :required => true
  timestamps :at
  has n, :quizzes
  has n, :text_messages
  has n, :subscribers
end
