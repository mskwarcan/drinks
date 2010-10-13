class BarEvent
  include DataMapper::Resource
  
  property :id,          Serial
  property :bar_id,      Integer
  property :title,       String, :required => true
  property :date,        Date
  property :description, Text, :required => true
  property :start_time,  String, :required => true
  property :end_time,    String, :required => true
  
  belongs_to :bar
end