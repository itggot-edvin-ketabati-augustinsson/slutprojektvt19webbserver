require 'sqlite3'

def open_db_link()
    db = SQLite3::Database.new('qna.db')
    db.results_as_hash = true
end

def open_db_link_nohash()
    db = SQLite3::Database.new('qna.db')
    db.results_as_hash = false
end