#!/usr/bin/env ruby

require 'pg'
require 'pp'

production_database = 'prism'
development_database = 'prism_develop'

conn = PG.connect(dbname: production_database)

conn.exec("SELECT * FROM Users") do |result|
  result.each do |row|
    pp row.values_at('id')
  end
end
