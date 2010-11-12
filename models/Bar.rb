require "dm-geokit"

class Bar
  
  include DataMapper::Resource
  include DataMapper::GeoKit
  
  property :id,         Serial
  property :person_id,  Integer
  property :name,       String, :required => true
  property :address,    String, :required => true
  property :city,       String, :required => true
  property :state,      String, :required => true
  property :latlon,     String
  property :zip,        String, :required => true
  property :phone,      String, :required => true
  property :url,        String
  property :description,Text
  property :created_at, DateTime
  property :updated_at, DateTime
  
  #has_geographic_location :address
  belongs_to :person
  
  has n, :clicks
  has n, :days, :child_key => [:bar_id]
  has n, :bar_events, 'BarEvent', :parent_key => [ :id ], :child_key => [:bar_id]
  has n, :specials,:child_key  => [:bar_id]

  def self.authenticate(id, user)
    return true if Bar.first(:person_id => user, :id => id)
  end
end

class Event
  include DataMapper::Resource
  
  property :id,          Serial
  property :title,       String
  
end

class Click
  include DataMapper::Resource
  
  property :id,         Serial
  property :ip_address, String
  property :created_at, DateTime
  
  belongs_to :bar
  
end