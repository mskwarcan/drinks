class Special
  include DataMapper::Resource
  
  property :id,          Serial
  property :bar_id,      Integer
  property :drink_name,  String
  property :price,       String
  property :type,        String
  property :day_of_week, String
  
  belongs_to :bar
  
end