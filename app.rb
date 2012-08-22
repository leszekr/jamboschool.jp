require 'sinatra'
require 'rubygems' 
require 'sinatra/r18n'

enable :sessions
R18n.set('en')

get '/' do
	erb :home
end
