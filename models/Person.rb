require 'helpers/helpers'
require 'digest/sha1'
require 'dm-validations'
require 'date'

class Person
  include DataMapper::Resource
  
  property :id,               Serial
  property :name,             String
  property :phone,            String
  property :email,            String, :required => true, :unique => true, :format => :email_address
  property :hashed_password,  String
  property :salt,             String
  property :created_at,       DateTime, :default => DateTime.now
  
  has n, :bars, :child_key => [:person_id]
  validates_presence_of :hashed_password, :name

  def password=(pass)
    @password = pass
    self.salt = Helpers::random_string(10) unless self.salt
    self.hashed_password = Person.encrypt(@password, self.salt)
  end

  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass + salt)
  end
  
  def self.authenticate(email, pass)
    u = Person.first(:email => email)
    return nil if u.nil?
    return u if Person.encrypt(pass, u.salt) == u.hashed_password
    nil
  end
end