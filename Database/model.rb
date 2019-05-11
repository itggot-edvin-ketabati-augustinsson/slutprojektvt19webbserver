module Model
    def self.open_db_link()
        db = SQLite3::Database.new('Database/qna.db')
        db.results_as_hash = true
        return db
    end

    def self.open_db_link_nohash()
        db = SQLite3::Database.new('Database/qna.db')
        return db
    end

    module User
        def self.register(name, pass, repeat_pass)
            db = Model::open_db_link_nohash()
            user = db.execute("SELECT UserId FROM users WHERE Username = (?)", name)
            if user[0] != nil 
                return result  = {
                    error: true,
                    message: "User with this name already exists."
                }
            end
            if repeat_pass == pass
                password = BCrypt::Password.create(pass)
                db.execute("INSERT INTO users(Username, Password) VALUES( (?), (?) )",name, password)
                return result = {
                    error: false,
                }
            else
                return result = {
                    error: true,
                    message: "Passwords don't match."
                }
            end
        end

        def self.login(name, pass)
            db = Model::open_db_link()
            result = db.execute("SELECT Password, UserId FROM users WHERE Username =(?)", name)
            unless result[0] != nil
                return loginfo = {
                    message: "Incorrect username or password"
                }
            end
            encrypted_pass = result[0]["Password"]
            if BCrypt::Password.new(encrypted_pass) == pass
                return loginfo = {
                    loggedin: true,
                    user_id: result[0]["UserId"],
                }
            else
                return loginfo = {
                    message: "Incorrect username or password",
                }
            end
        end

        def self.fetch_users()
            db = Model::open_db_link()
            return db.execute("SELECT UserId, Username FROM users")
        end

    end

    module Question
        def self.fetch_all()
            db = Model::open_db_link()
            return db.execute("SELECT questions.QuestionId, questions.FromId, questions.ToId, questions.Answer, questions.Question, users.Username FROM questions INNER JOIN users ON questions.FromId = users.UserId")
        end

        def self.get_questions(user_id)
            db = Model::open_db_link()
            return db.execute("SELECT questions.QuestionId, questions.FromId, questions.ToId, questions.Answer, questions.Question, users.Username FROM questions INNER JOIN users ON questions.FromId = users.UserId WHERE questions.ToId =(?)", user_id)
        end
        
        def self.get_asked_questions(user_id)
            db = Model::open_db_link()
            return db.execute("SELECT questions.QuestionId, questions.FromId, questions.ToId, questions.Answer, questions.Question, users.Username FROM questions INNER JOIN users ON questions.ToId = users.UserId WHERE FromId =(?)", user_id)
        end

        def self.answer_question(id, answer)
            db = Model::open_db_link_nohash()
            db.execute("UPDATE questions SET answer =(?) WHERE QuestionId = (?)",answer, id)
        end

        def self.ask(to_id,from_id,question)
            db = Model::open_db_link_nohash()
            db.execute("INSERT INTO questions(ToId, FromId, Question) VALUES( (?),(?),(?) )",to_id,from_id,question)
        end

        def self.delete(id)
            db = Model::open_db_link_nohash()
            db.execute("DELETE FROM questions WHERE QuestionId = (?)", id)
            db.execute("DELETE FROM likes WHERE QuestionId = (?)", id)
        end

        def self.fetch_likes()
            db = Model::open_db_link()
            return db.execute("SELECT * FROM likes")
        end

        def self.like(qid,uid)
            db = Model::open_db_link_nohash()
            already_liked = db.execute("SELECT QuestionId FROM likes WHERE UserId = ?",uid)
            already_liked = already_liked.flatten()
            if already_liked.include? qid.to_i
                return error = {
                    error: true,
                    message: "You have already liked this post",
                } 
            else
                db.execute("INSERT INTO likes(QuestionId, UserId) VALUES(?,?)",qid,uid)
                return error= {
                    error: false,
                }
            end
        end

    end

end