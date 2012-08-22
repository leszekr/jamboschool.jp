require 'sinatra'
require 'rubygems' 
require 'sinatra/r18n'

enable :sessions
R18n.set('en')

set :markdown, :layout_engine => :erb, :layout => :layout


before do
	@m = {
		:home => "",
		:classes => "",
		:about => "",
		:fun => "",
		:contact => ""
	}
end

get '/' do
	@m[:home] = "active"
	@body_class="home-page"
	erb :home
end

get '/classes' do
	@m[:classes] = "active"
	erb :classes
end

get '/about' do
	@m[:about] = "active"
	erb :about
end

get '/fun' do
	@m[:fun] = "active"
	erb :fun
end

get '/contact' do
	@m[:contact] = "active"
	erb :contact
end

not_found do
	erb :'404'
end