class PrizeList
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true, :length => 255
  property :description, Text
  property :image_url, String, :length => 255
  property :claimed, Boolean, :required => true, :default => false
end