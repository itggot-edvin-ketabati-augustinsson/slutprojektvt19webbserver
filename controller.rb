require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require_relative './Database/model.rb'

enable :sessions

secure_routes = ['/profile']

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

post('/create') do
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
    slim(:"Profile/profile")
end

get('/error') do
    session.destroy
    slim(:"Error/error")
end