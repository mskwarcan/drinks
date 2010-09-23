require 'rubygems'
require 'data_mapper'
require 'models/Person'
require 'models/BarEvent'
require 'models/Day'
require 'models/Bar'
require 'models/Special'
#require 'models/Location'


DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/bars.db")

#Create or upgrade all tables
DataMapper.auto_upgrade!