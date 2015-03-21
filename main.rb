require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'asdflkj'

helpers do
  def calc_total(cards)
    total = 0
    #total up non-ace cards
    non_aces = cards.select {|card| card.first != 'Ace'}
    non_aces.each do |card|
      card.first.to_i == 0 ? total += 10 : total += card.first.to_i
    end
    #count number of aces and add to total
    num_aces = cards.select {|card| card.first == 'Ace'}.count
    num_aces.times do
      total + 11 > 21 ? total += 1 : total += 11
    end
    #return total
    total    
  end

  def get_card_img(card)
    '/images/cards/' + card.last.downcase + '_' + card.first.downcase + '.jpg'
  end

  def dealer_turn
    @show_all_cards = true
    @show_buttons = false
    @show_dealer_button = true 
  end

  def winner(msg)
    @game_over = true
    @show_buttons = false
    @show_dealer_button = false
    @show_all_cards = true
    @win = msg + " You won #{session[:bet_amount]} chips!"
    session[:player_pot] += session[:bet_amount]
  end

  def loser(msg)
    @game_over = true
    @show_buttons = false
    @show_dealer_button = false
    @show_all_cards = true
    @lose = msg + " You lost #{session[:bet_amount]} chips!"
    session[:player_pot] -= session[:bet_amount]
    if session[:player_pot] == 0
      @broke = true
    end
  end

  def push(msg)
    @game_over = true
    @show_buttons = false
    @show_dealer_button = false
    @show_all_cards = true
    @push = msg + " Push!"
  end
end

before do
  @show_buttons = true
end

get '/' do
  if session[:player_name]
    redirect '/new_game'
  else
    redirect :set_name
  end
end

get '/set_name' do
  erb :set_name
end

post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/new_game'
end

get '/new_game' do
  erb :new_game
end

post '/new_game' do
  session[:player_pot] = 1000
  redirect '/bet'
end

get '/bet' do
  session[:bet_amount] = nil
  erb :bet
end

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
    @error = "Please make a valid bet."
    halt erb :bet
  elsif params[:bet_amount].to_i > session[:player_pot]
    @error = "You don't have enough chips! Try again."
    halt erb :bet
  else
    session[:bet_amount] = params[:bet_amount].to_i
    redirect '/game'
  end
end  

get '/game' do
  #initialize deck of cards
  session[:deck] = []
  ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'].each do |face|
    ['Hearts', 'Diamonds', 'Spades', 'Clubs'].each do |suit|
      session[:deck].push([face, suit])
    end
  end
  session[:deck].shuffle!
  #initialize player and dealer hands
  session[:player_cards] = []
  session[:dealer_cards] = []
  2.times do
    session[:player_cards].push(session[:deck].pop)
    session[:dealer_cards].push(session[:deck].pop)
  end
  #check for blackjacks
  if calc_total(session[:player_cards]) == 21
    winner("Congrats you hit blackjack!") 
  elsif calc_total(session[:dealer_cards]) == 21
    loser("Dealer hit blackjack.")
  else
    erb :game
  end 
end

post '/player/hit' do
  session[:player_cards].push(session[:deck].pop)
  if calc_total(session[:player_cards]) > 21
    loser("Bust!")
  end  
  erb :game, layout: false
end

post '/stay' do
  dealer_turn
  if calc_total(session[:dealer_cards]) > 16
    redirect '/game/compare'
  else 
    erb :game, layout: false
  end
end

post '/dealer/hit' do
  dealer_turn
  session[:dealer_cards].push(session[:deck].pop)
  if calc_total(session[:dealer_cards]) > 21
    winner("Dealer busted.")
  elsif calc_total(session[:dealer_cards]) > 16
    redirect '/game/compare'
  end
  erb :game, layout: false
end

get '/game/compare' do
  dealer_total = calc_total(session[:dealer_cards])
  player_total = calc_total(session[:player_cards])

  if dealer_total > player_total
    loser("Dealer has #{dealer_total} and you have #{player_total}.")
  elsif player_total > dealer_total
    winner("You have #{player_total} and dealer has #{dealer_total}.")
  else
    push("Player and dealer both have #{player_total}.")
  end
  erb :game, layout: false
end

get '/gameover' do
  erb :game_over
end

get '/broke' do
  erb :broke
end

post '/rebet' do
  redirect '/game'
end