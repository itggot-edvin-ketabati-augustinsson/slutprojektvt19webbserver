require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require_relative './Database/model.rb'

enable :sessions

secure_routes = ['/profile','/answer','/recieved','/browse','/delete/:id']

before do
    if secure_routes.include? request.path()
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
    register(params["name"], params["pass"])
    redirect('/')
end

post('/login') do
    if login(params["name"], params["pass"]) == true
        redirect('/profile')
    else
        redirect('/error')
    end
end

get('/profile') do
    questions = get_asked_questions(session[:user_id])
    slim(:"Profile/profile", locals:{
        questions: questions,
    })
end

get('/error') do
    session.destroy
    slim(:"Error/error")
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
        ask(to_id,from_id,question)
        redirect('/profile')
    else
        redirect('/error')
    end
end

post('/answer/:id') do 
    question_id = params["id"].to_i
    answer = params["answer"]
    answer_question(question_id, answer)
    redirect('/recieved')
end

get('/recieved') do
    questions = get_questions(session[:user_id])
    slim(:"Questions/recieved", locals:{
        questions: questions,
    })
end

get('/browse') do
    users = fetch_users()
    slim(:"Profile/browse", locals:{
        users: users,
    })
end

post('/delete/:id') do
    delete(params["id"])
    redirect('/profile')
end