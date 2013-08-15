class User

  include DataMapper::Resource
  property :id, Serial
  property :username, String, :required => true
  
end