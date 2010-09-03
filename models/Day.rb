class Day
  include DataMapper::Resource
  
  property :id,          Serial
  property :bar_id,      Integer
  property :day_of_week, String
  property :open,        String
  property :close,       String
  property :closed,      String
  property :cover,       String
  
  belongs_to :bar
end