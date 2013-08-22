class User

  include DataMapper::Resource
  property :id, Serial
  property :uid, String, :required => true
  property :provider, String, :required => true, :default => "app"
  property :name, String

  def self.first_or_create_from_provider(uid, provider)
  	u = first_or_create({:uid => uid, :provider => provider})
  	return u.save ? u : false
  end

  def self.first_or_create_from_omniauth(auth)
    u = first_or_create({:uid => auth[:uid], :provider => auth[:provider]})
    u.name = auth[:info][:name] unless auth[:info][:name].nil?
    return u.save ? u : false
  end
  
end