require 'rubygems'
require 'sinatra'
require 'coffee-script'

set :run, true

get '/assets/application.js' do
  coffee :application, views: './views'
end

get '/' do
  File.read(File.join('public', 'index.html'))
end