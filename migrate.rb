#!/usr/bin/env ruby

require 'pg'
require 'pp'

production_database = 'prism'
development_database = 'prism_development'

file_name = 'migration.sql'

doc9 = "24296ef2-aea5-11e2-80bf-c82a14fffe99"
doc10 = "3b56ee42-aea5-11e2-80bf-c82a14fffe99"
doc11 = "4213c156-aea5-11e2-80bf-c82a14fffe99"
doc12 = "480e952c-aea5-11e2-80bf-c82a14fffe99"

$doc_map = {
  "9" => "24296ef2-aea5-11e2-80bf-c82a14fffe99",
  "10" => "3b56ee42-aea5-11e2-80bf-c82a14fffe99",
  "11" => "4213c156-aea5-11e2-80bf-c82a14fffe99",
  "12" => "480e952c-aea5-11e2-80bf-c82a14fffe99"
}


$conn = PG.connect(dbname: production_database)
$db = PG.connect(dbname: development_database)
$db.set_error_verbosity(PG::PQERRORS_VERBOSE)


users_sql = ""
facets_sql = ""

$conn.exec("SELECT * FROM Users") do |result|
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

def migrate_facets

  facet_counter = 1
  $conn.exec("SELECT * FROM facets") do |results|
    results.each do |row|

      id = row.values_at('id').first
      color = row.values_at('color').first
      description = row.values_at('category').first
      created_at = row.values_at('created_at').first
      updated_at = row.values_at('updated_at').first
      prism_id = $doc_map[row.values_at('prism_id').first]

      $db.prepare("facets#{facet_counter}", "INSERT INTO facets(id, color, description, created_at, updated_at, prism_id) VALUES($1, $2, $3, $4, $5, $6)")

      $db.exec_prepared("facets#{facet_counter}", [id, color, description, created_at, updated_at, prism_id])
      facet_counter += 1
    end


  end
end

def migrate_docs
  doc_counter = 1

  $conn.exec("SELECT * FROM documents") do |results|
    results.each do |row|
      uuid =  $doc_map[row.values_at('id').first]
      title = row.values_at('title').first
      author = row.values_at('author').first
      content = row.values_at('content').first
      num_words = row.values_at('num_words').first
      description = row.values_at('description').first
      publication_date = row.values_at('pub_date').first
      created_at =  row.values_at('created_at').first
      updated_at = row.values_at('updated_at').first
      license = 'none'

      $db.prepare("docs#{doc_counter}", "INSERT INTO prisms(uuid, title, author, content, num_words, description, publication_date, license, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)")
      $db.exec_prepared("docs#{doc_counter}", [uuid, title, author, content, num_words, description, publication_date, license, created_at, updated_at]);

      doc_counter += 1
    end
  end
end

migrate_docs
#migrate_facets

#File.open(file_name, 'w') { |file| file.write(users_sql) }

