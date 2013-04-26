#!/usr/bin/env ruby

require 'pg'
require 'pp'

production_database = 'prism'
development_database = 'prism_develop'

file_name = 'migration.sql'

doc9 = "24296ef2-aea5-11e2-80bf-c82a14fffe99"
doc10 = "3b56ee42-aea5-11e2-80bf-c82a14fffe99"
doc11 = "4213c156-aea5-11e2-80bf-c82a14fffe99"
doc12 = "480e952c-aea5-11e2-80bf-c82a14fffe99"


conn = PG.connect(dbname: production_database)

users_sql = ""

conn.exec("SELECT * FROM Users") do |result|
  result.each do |row|
    users_sql += "INSERT INTO users(id, email, encrypted_password, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, created_at, updated_at) 
    VALUES( %s, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');\n\n" %
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

conn.exec("SELECT * FROM FACETS") do |result|

end



File.open(file_name, 'w') { |file| file.write(users_sql) }

