require 'sinatra'
require 'rubygems' 
require 'mail'
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
	@error = ""
	erb :contact
end


post '/contact/?' do
	@contact_email = params['contact_email']||""
	@contact_name = params['contact_name']
	@contact_phone = params['contact_phone']
	@contact_message = params['contact_message']||""

  	if @contact_email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
  		mailspec = {
	  		:from => 'Jambo School Page <page_form@jamboschool.jp>',
			:to  => 'webmaster@jamboschool.jp',
			:subject  => "Message from #{params[:contact_name]||'someone'} in the Jambo School page",
			:body   =>  "David:\r\n\r\n #{params[:contact_name]||'someone'} (#{params[:contact_email]||''} writes:\r\n#{params[:contact_message]}"
		}
  		mail = Mail.new(mailspec)
		mail.delivery_method :sendmail
		mail.deliver
		@error = "";
		@thank_you = true
		erb :contact
	else
		@error = "E-mail is invalid"
		@m[:contact] = "active"
		erb :contact
	end


end

not_found do
	erb :'404'
end