require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/flash'
require_relative './Database/model.rb'

include Model

enable :sessions
set :show_exceptions, :after_handler

insecure_routes = ['/','/register','/create_account','/login','/logout', '/notloggedin']

before do
    unless insecure_routes.include? request.path()
        if session[:loggedin] != true
            redirect('/notloggedin')
        end 
    end
end

# Displays first page
#
get('/') do
    slim(:"Profile/login")
end

# Displays register view
#
get('/register') do
    slim(:"Profile/register")
end

# Creates a new account and validates input data, redirects to /
#
# @param [String] name, The username of the account 
# @param [String] pass, The unencrypted password inputted
# @param [String] repeat_pass, The unencrypted password inputted second time by user
#
# See Model#User#register
post('/create_account') do
    result = User.register(params["name"], params["pass"], params["repeat_pass"])       #FIXA VALIDERING AV TOM INPUT
    if result[:error] == false
        redirect('/')
    else
        flash[:error] = result[:message]
        redirect back
    end
end

# Checks input data and logs user in, redirects to /profile
#
# @param [String] name, The username of the account 
# @param [String] pass, The unencrypted password inputted
#
# See Model#User#login
post('/login') do
    loginfo = User.login(params["name"], params["pass"])
    if loginfo[:loggedin] == true
        session[:loggedin] = true
        session[:user_id] = loginfo[:user_id]
        redirect('/profile')
    else
        flash[:error] = loginfo[:message]
        redirect back
    end
end

# Displays the users profile page and questions
#
# @param [Integer] user_id, The users unique ID
#
# See Model#Question#get_asked_questions
get('/profile') do
    questions = Question.get_asked_questions(session[:user_id])
    slim(:"Profile/profile", locals:{
        questions: questions,
    })
end

# Logs the user out, redirects to /
#
post('/logout') do
    session.destroy
    redirect('/')
end

# Asks another user the inputted question, redirects to /profile
#
# @param [Integer] from_id, Unique ID of the user asking
# @param [Integer] to_id, Unique ID of the user being asked
# @param [String] question, The question being asked
#
# See Model#Question#ask
post('/ask/:id') do
   from_id = session[:user_id]
   to_id = params["id"].to_i
   question = params["question"]
    if to_id != from_id
        Question.ask(to_id,from_id,question)
        redirect('/profile')
    else
        "You can't ask yourself a question!"
    end
end

# Answers a users question, redirects to /recieved
#
# @param [Integer] question_id, The unique ID of the question being answered
# @param [String] answer, The contents of the answer
#
# See Model#Question#answer_question
post('/answer/:id') do 
    question_id = params["id"].to_i             #FIXA MATCHANDE ID
    answer = params["answer"]
    Question.answer_question(question_id, answer)
    redirect('/recieved')
end

# Displays all questions asked to a user
#
# @param [Integer] user_id, The unique ID of the user whose questions are displayed
#
# See Model#Question#get_questions
get('/recieved') do
    questions = Question.get_questions(session[:user_id])
    slim(:"Questions/recieved", locals:{
        questions: questions,
    })
end

get('/browse') do
    users = User.fetch_users()
    slim(:"Questions/browse", locals:{
        users: users,
    })
end

get('/all_questions') do
    likes = Question.fetch_likes()
    questions = Question.fetch_all()
    slim(:"Questions/all_questions", locals:{
        questions: questions,
        likes: likes,
    })
end

post('/delete/:id') do
    Question.delete(params["id"]) # FIXA MATCHANDE ID
    redirect('/profile')
end

post('/like/:id') do
    qid = params["id"]
    uid = session[:user_id]
    result = Question.like(qid,uid)
    if result[:error] == true
        result[:message]
    else
        redirect('/all_questions')
    end
end

error 404 do
    slim(:"Error/error_404")
end

error 500 do
    slim(:"Error/error_500")
end

error do
    slim(:"Error/error", locals:{
        error: env['sinatra.error'].message,
    })
end

get('/notloggedin') do
    session.destroy
    slim(:"Error/error_auth")
end