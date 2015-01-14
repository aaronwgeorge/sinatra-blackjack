require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
  erb :set_name
end

post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/deal'
end

get '/deal' do
  erb :deal
end

post '/game' do
  session[:deck] = []
  ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'].each do |face|
    ['Hearts', 'Diamonds', 'Spades', 'Clubs'].each do |suit|
      session[:deck].push([face, suit])
    end
  end
  session[:deck].shuffle!
  session[:player_cards] = [session[:deck].pop, session[:deck].pop]
  erb :game
end