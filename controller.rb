require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require_relative './Database/model.rb'

get('/') do
    slim(:"Profile/login")
end