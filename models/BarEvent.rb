class BarEvent
  include DataMapper::Resource
  
  property :id,          Serial
  property :bar_id,      Integer
  property :title,       String
  property :day_of_week, String
  property :start_time,  String
  property :end_time,    String
  
  belongs_to :bar
end