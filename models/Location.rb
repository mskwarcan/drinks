class Location
  include DataMapper::Resource
  include DataMapper::GeoKit
  property :id, Serial
  has_geographic_location :address
end
