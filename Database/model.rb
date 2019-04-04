require 'sqlite3'

def open_db_link()
    db = SQLite3::Database.new('Database/qna.db')
    db.results_as_hash = true
    return db
end

def open_db_link_nohash()
    db = SQLite3::Database.new('Database/qna.db')
    db.results_as_hash = false
    return db
end

def register(name, pass)
    db = open_db_link()
    password = BCrypt::Password.create(pass)
    db.execute("INSERT INTO users(Username, Password) VALUES( (?), (?) )",name, password)
end

def login(name, pass)
    db = open_db_link()
    result = db.execute("SELECT Password, UserId FROM users WHERE Username =(?)", name)
    encrypted_pass = result[0]["Password"]
    if BCrypt::Password.new(encrypted_pass) == pass
        session[:loggedin] = true
        session[:user_id] = result[0]["UserId"]
        session[:name] = name
        return true
    else
        return false
    end
end