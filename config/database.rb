require 'rubygems'
require 'data_mapper'
require 'models/Person'
require 'models/BarEvent'
require 'models/Day'
require 'models/Bar'
require 'models/Special'


DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://bars.db')

#Create or upgrade all tables
DataMapper.auto_upgrade!