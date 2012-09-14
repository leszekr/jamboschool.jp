require 'sinatra'
require 'rubygems' 
require 'mail'
require 'sinatra/r18n'

enable :sessions

set :markdown, :layout_engine => :erb, :layout => :layout


R18n.set("ja")
R18n::I18n.default = "ja"


before do
	@m = {
		:home => "",
		:classes => "",
		:about => "",
		:fun => "",
		:contact => ""
	}
   	session[:locale] = params[:lang] if params[:lang]

   	session[:locale] ||= "ja"

	@title = t.title
	@keywords = t.keywords
	@subtitle = ""
end


get '/' do
	@m[:home] = "active"
	@body_class="home-page"
	erb :"/#{session[:locale]}/home"
end

get '/classes' do
	@m[:classes] = "active"
	@subtitle = t.menu.classes
	erb :"/#{session[:locale]}/classes"
end

get '/about' do
	@m[:about] = "active"
	@subtitle = t.menu.about
	erb :"/#{session[:locale]}/about"
end

get '/fun' do
	@m[:fun] = "active"
	@subtitle = t.menu.fun
	markdown :"/#{session[:locale]}/fun"
end

get '/contact' do
	response.headers["X-Frame-Options"] = "GOFORIT"
	@m[:contact] = "active"
	@error = ""
	@subtitle = t.menu.contact
	erb :"/#{session[:locale]}/contact"
end


post '/contact/?' do
	@contact_email = params['contact_email']||""
	@contact_name = params['contact_name']
	@contact_phone = params['contact_phone']
	@contact_message = params['contact_message']||""

  	if @contact_email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
  		mailspec = {
	  		:from => 'Jambo School Page <page_form@jamboschool.jp>',
			:to  => 'david@jamboschool.jp, webmaster@jamboschool.jp',
			:subject  => "Message from #{params[:contact_name]||'someone'} in the Jambo School page",
			:body   =>  "David:\r\n\r\n #{params[:contact_name]||'someone'} (#{params[:contact_email]||''}) writes:\r\n\r\n---\r\n#{params[:contact_message]}\r\n\r\n---"
		}
  		mail = Mail.new(mailspec)
		mail.delivery_method :sendmail
		mail.deliver
		@error = "";
		@thank_you = true
		@subtitle = "ありがとう"
		erb :contact
	else
		@error = "メールは無効です"
		@subtitle = "連絡先　ー　エラー"
		@m[:contact] = "active"
		erb :contact
	end


end

not_found do
	erb :'404'
end