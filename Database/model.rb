module Model
    
    # Attempts to establish a connection to the database with results as hash
    #
    # @return [SQLite3::Database] Containing connection to database
    def self.open_db_link()
        db = SQLite3::Database.new('Database/qna.db')
        db.results_as_hash = true
        return db
    end

    # Attempts to establish a connection to the database with results as array
    #
    # @return [SQLite3::Database] Containing connection to database
    def self.open_db_link_nohash()
        db = SQLite3::Database.new('Database/qna.db')
        return db
    end

    module User

        # Attempts to create a new user
        #
        # @param [String] name, The name of the user to create
        # @param [String] pass, The password connected to the user
        # @param [String] repeat_pass, The second password entered by user to validate form data
        # 
        # @return [Hash]
        #   * :error [Boolean] whether an error occured
        #   * :message [String] the error message if an error occured
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

        # Attempts to login existing user
        #
        # @param [String] name, The name of the user to create
        # @param [String] pass, The password connected to the user
        # 
        # @return [Hash]
        #   * :loggedin [Boolean] If the login was successful
        #   * :message [String] the error message if an error occured
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
        
        # Attempts to fetch all registered users
        #
        # @return [Hash] Containing all users and their ID
        def self.fetch_users()
            db = Model::open_db_link()
            return db.execute("SELECT UserId, Username FROM users")
        end

    end

    module Question

        # Attempts to fetch all questions and the users they were asked by
        #
        # @return [Hash] Containing all questions and the users who asked them
        def self.fetch_all()
            db = Model::open_db_link()
            return db.execute("SELECT questions.QuestionId, questions.FromId, questions.ToId, questions.Answer, questions.Question, users.Username FROM questions INNER JOIN users ON questions.FromId = users.UserId")
        end

        # Attempts to fetch all questions asked to specific user
        #
        # @param [Integer] user_id, The ID of the user the questions where asked to
        #
        # @return [Hash] Containing all questions and the users who asked them
        def self.get_questions(user_id)
            db = Model::open_db_link()
            return db.execute("SELECT questions.QuestionId, questions.FromId, questions.ToId, questions.Answer, questions.Question, users.Username FROM questions INNER JOIN users ON questions.FromId = users.UserId WHERE questions.ToId =(?)", user_id)
        end
        
        # Attempts to fetch all questions asked by specific user
        #
        # @param [Integer] user_id, The ID of the user the questions where asked by
        #
        # @return [Hash] Containing all questions and the users they were asked to
        def self.get_asked_questions(user_id)
            db = Model::open_db_link()
            return db.execute("SELECT questions.QuestionId, questions.FromId, questions.ToId, questions.Answer, questions.Question, users.Username FROM questions INNER JOIN users ON questions.ToId = users.UserId WHERE FromId =(?)", user_id)
        end

        # Attempts to answer a specific question
        #
        # @param [Integer] id, The ID of the question being answered
        # @param [String] answer, The answer to the question
        #
        def self.answer_question(id, answer)
            db = Model::open_db_link_nohash()
            db.execute("UPDATE questions SET answer =(?) WHERE QuestionId = (?)",answer, id)
        end

        # Attempts to ask a question
        #
        # @param [Integer] to_id, The ID of the user being asked
        # @param [String] question, The question
        # @param [Integer] from_id, The ID of the user asking the question
        #
        def self.ask(to_id,from_id,question)
            db = Model::open_db_link_nohash()
            db.execute("INSERT INTO questions(ToId, FromId, Question) VALUES( (?),(?),(?) )",to_id,from_id,question)
        end

        # Attempts to delete a question
        #
        # @param [Integer] id, The ID of the question being deleted
        #
        def self.delete(id)
            db = Model::open_db_link_nohash()
            db.execute("DELETE FROM questions WHERE QuestionId = (?)", id)
            db.execute("DELETE FROM likes WHERE QuestionId = (?)", id)  
        end

        # Attempts to fetch all likes
        #
        # @return [Hash] containg all likes, the users who liked, the question that was liked
        #
        def self.fetch_likes()
            db = Model::open_db_link()
            return db.execute("SELECT * FROM likes")
        end

        # Attempts to like a post
        #
        # @param [Integer] qid, The ID of the question being liked
        # @param [Integer] uid, The ID of the user liking
        # 
        # @return [Hash]
        #   * :error [Boolean] Whether an error occured or not
        #   * :message [String] the error message if an error occured
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