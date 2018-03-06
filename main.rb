require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'json'

enable :sessions

get '/' do
  if session[:name] && session[:roomno]
    redirect :room
  else
    session[:roomno] = nil
  end
  slim :index
end

get '/logout' do
  session.clear
  redirect '/'
end

post '/room' do
  id = rand(100)
  session[:id] = id
  session[:name] = params[:name]
  session[:roomno] = params[:roomno]
  @roomno = session[:roomno]
  @room = { users: [] }
  p @room
  if File.exist? "data/room#{@roomno}.txt"
    File.open("data/room#{@roomno}.txt", 'r') do |f|
      @room = JSON.parse(f.readlines.join, symbolize_names: true)
    end
  end
  p @room
  @room[:users].push(name: session[:name])
  File.open("data/room#{@roomno}.txt", 'w') do |f|
    JSON.dump(@room, f)
  end
  @users = @room[:users]
  @username = session[:name]
  slim :room
end

get '/room' do
  params[:roomno] ||= nil
  @roomno = session[:roomno] || params[:roomno]
  redirect '/' unless @roomno
  @users = []
  File.open("data/room#{@roomno}.txt", 'r') do |f|
    json = JSON.parse(f.readlines.join, symbolize_names: true)
    @users = json[:users]
    p json
    p @users
  end
  @username = session[:name]
  slim :room
end

get '/sessions' do
  @session = session
  slim :session
end

get '/room_members/:no?' do |no|
  roomno = no || session[:roomno]
  redirect '/' unless roomno
  File.open("data/room#{roomno}.txt", 'r') do |f|
    @data = JSON.parse(f.readlines.join, symbolize_names: true)[:users]
  end
  @data.to_json
end

get '/chat/:no' do |no|
  begin
    File.open("data/chat#{no}.txt", 'r') do |f|
      @data = JSON.parse(f.readline, symbolize_names: true)
    end
  rescue Errno::ENOENT
    @data = []
  rescue EOFError
    @data = []
  end
  @data ||= []
  @data.to_json
end

post '/chat/:no' do |no|
  if File.exist? "data/chat#{no}.txt"
    File.open("data/chat#{no}.txt", 'r') do |f|
      @data = JSON.parse(f.readline, symbolize_names: true)
    end
  end
  @data ||= []
  name = params[:name] || nil
  message = params[:message] || nil
  if name && message
    @data.append(name: name, message: message)
    File.open "data/chat#{no}.txt", 'w' do |f|
      JSON.dump(@data, f)
    end
  end
  @data.to_json
end