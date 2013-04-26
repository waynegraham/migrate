#!/usr/bin/env ruby

require 'pg'
require 'pp'

production_database = 'prism'
development_database = 'prism_develop'

conn = PG.connect(dbname: production_database)

sql = ""

users_sql = ""

conn.exec("SELECT * FROM Users") do |result|
  result.each do |row|
    users_sql += "INSERT INTO users(id, email, encrypted_password, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, created_at, updated_at) 
    VALUES( %s, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');\n" %
      row.values_at(
        'id',
        'email',
        'encrypted_password',
        'sign_in_count',
        'current_sign_in_at',
        'last_sign_in_at',
        'current_sign_in_ip',
        'last_sign_in_ip',
        'created_at',
        'updated_at'
    )
  end
end



