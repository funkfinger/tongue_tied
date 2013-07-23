require 'data_mapper'

db_connection_string = "postgres://#{ENV['DB_USER']}:#{ENV['DB_PASS']}@#{ENV['DB_HOST']}/#{ENV['DB_NAME']}"
DataMapper.setup(:default, db_connection_string)

require_relative 'plivo'
require_relative 'betwext'
require_relative 'text_message'
require_relative 'keyword'
require_relative 'subscriber'
require_relative 'twilio'
require_relative 'campaign'

# DataMapper.auto_migrate!
DataMapper.finalize
DataMapper.auto_upgrade!
