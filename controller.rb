require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require_relative './Database/model.rb'

include Model

enable :sessions
set :show_exceptions, :after_handler

insecure_routes = ['/','/register','/create_account','/login','/logout', '/error']

before do
    unless insecure_routes.include? request.path()
        if session[:loggedin] != true
            redirect('/error')
        end 
    end
end

get('/') do
    slim(:"Profile/login")
end

get('/register') do
    slim(:"Profile/register")
end

post('/create_account') do
    User.register(params["name"], params["pass"])
    redirect('/')
end

post('/login') do
    loginfo = User.login(params["name"], params["pass"])
    if loginfo[:loggedin] == true
        session[:loggedin] = true
        session[:user_id] = loginfo[:user_id]
        redirect('/profile')
    else
        loginfo[:message]
    end
end

get('/profile') do
    questions = Question.get_asked_questions(session[:user_id])
    slim(:"Profile/profile", locals:{
        questions: questions,
    })
end

post('/logout') do
    session.destroy
    redirect('/')
end

post('/ask/:id') do
   from_id = session[:user_id]
   to_id = params["id"].to_i
   question = params["question"]
    if to_id != from_id
        Question.ask(to_id,from_id,question)
        redirect('/profile')
    else
        redirect('/error')
    end
end

post('/answer/:id') do 
    question_id = params["id"].to_i
    answer = params["answer"]
    Question.answer_question(question_id, answer)
    redirect('/recieved')
end

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
    Question.delete(params["id"])
    redirect('/profile')
end

post('/like/:id') do
    qid = params["id"]
    uid = session[:user_id]
    Question.like(qid,uid)
    redirect('/all_questions')
end

# error 404 do
#     slim(:"Error/error_404")
# end

# error 500 do
#     slim(:"Error/error_500")
# end

# error do
#     slim(:"Error/error", locals:{
#         error: env['sinatra.error'].message,
#     })
# end

get('/error') do
    session.destroy
    slim(:"Error/error_auth")
end