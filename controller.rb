require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require_relative './Database/model.rb'

enable :sessions

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

get('/error') do
    slim(:"Error/error")
end