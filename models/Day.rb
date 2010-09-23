class Day
  include DataMapper::Resource
  
  property :id,          Serial
  property :bar_id,      Integer
  property :day_of_week, String, :required => true
  property :open,        String, :required => true
  property :close,       String, :required => true
  property :closed,      String
  property :cover,       String
  
  belongs_to :bar
end