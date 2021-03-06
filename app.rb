require 'sinatra'
require 'rubygems' 
require 'mail'
require 'sinatra/r18n'
require 'open-uri'
require 'json'

enable :sessions
  set :session_secret, "Persistence"
#  set :protection, except: :session_hijacking

set :markdown, :layout_engine => :erb, :layout => :layout

server = "http://fun.jamboschool.jp/"


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

	# read in newest post
	begin
		stream = open(server+"\?json=1&count=1&lang=#{session[:locale]}")
		result = JSON.parse(stream.read)
		@activepost = result["posts"][0]
		stream.close

		# read in active post in the other language
		stream = open(server+"\?json=get_post&id=#{@activepost["id"]}&lang=#{t.otherlang}")
		result = JSON.parse(stream.read)
		@otherlang = result["post"]
		stream.close
	rescue
		@activepost = {:slug=>"", :date=>"", :title=>""}
		@otherlang = {:slug=>"", :date=>"", :title=>""}
	end


	erb :home
end

get '/classes' do
	@m[:classes] = "active"
	@subtitle = t.menu.classes
	erb :"/#{session[:locale]}/classes"
end

get '/classes/:class' do
	@m[:classes] = "active"
	@subtitle = t.menu.classes
	erb :"/#{session[:locale]}/classes/#{params[:class]}"
end

get '/teachers' do
	@m[:about] = "active"
	@subtitle = t.menu.teachers
	erb :"/#{session[:locale]}/teachers"
end

get '/about' do
	@m[:about] = "active"
	@subtitle = t.menu.about
	erb :"/#{session[:locale]}/about"
end

get '/benefits' do
	@m[:about] = "active"
	@subtitle = t.menu.benefits
	erb :"/#{session[:locale]}/benefits"
end

get '/oldfun' do
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

get '/fun/?:post_id?' do

	#read in list of categories
	stream = open(server+"/?json=get_category_index&lang=#{session[:locale]}")
	result = JSON.parse(stream.read)
	@categories = result["categories"]
	stream.close

	# read in all posts
	stream = open(server+"\?json=1&count=30&lang=#{session[:locale]}")
	result = JSON.parse(stream.read)
	@posts = result["posts"]
	stream.close

	# if activepost in parameter p, load that. else - first in list (most recent)
	post_id = params["post_id"].to_i || -1
	@activepost = @posts[0]
	@posts.each_with_index do |post, i|
		if post["id"] == post_id
			@activepost = post
		end
	end

	# read in active post in the other language
	stream = open(server+"\?json=get_post&id=#{@activepost["id"]}&lang=#{t.otherlang}")
	result = JSON.parse(stream.read)
	@otherlang = result["post"]
	stream.close

	@m[:fun] = "active"
	@subtitle = t.menu.fun+" - "+@activepost["categories"][0]["title"]+" - "+@activepost["title"]
	erb :fun
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
		@subtitle = t.message.thankyou
		erb :contact
	else
		@error = t.message.mail_error
		@subtitle = t.menu.contact_error
		@m[:contact] = "active"
		erb :contact
	end


end

not_found do
	erb :"404"
end
