require 'sqlite3'
require 'bcrypt'

def open_db_link()
    db = SQLite3::Database.new('Database/qna.db')
    db.results_as_hash = true
    return db
end

def open_db_link_nohash()
    db = SQLite3::Database.new('Database/qna.db')
    return db
end

def register(name, pass)
    db = open_db_link_nohash()
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

def get_questions(user_id)
    db = open_db_link()
    return db.execute("SELECT * FROM questions WHERE ToId =(?)", user_id)
end

def get_asked_questions(user_id)
    db = open_db_link()
    return db.execute("SELECT * FROM questions WHERE FromId =(?)", user_id)
end

def answer_question(id, answer)
    db = open_db_link_nohash()
    db.execute("UPDATE questions SET answer =(?) WHERE QuestionId = (?)",answer, id)
end

def ask(to_id,from_id,question)
    db = open_db_link_nohash()
    db.execute("INSERT INTO questions(ToId, FromId, Question) VALUES( (?),(?),(?) )",to_id,from_id,question)
end

def fetch_users()
    db = open_db_link()
    return db.execute("SELECT UserId, Username FROM users")
end