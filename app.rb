require 'debug'
require 'awesome_print'
require 'securerandom'
require 'sinatra/base'
require_relative 'config'

class App < Sinatra::Base
  setup_development_features(self)

  enable :sessions
  set :session_secret, SecureRandom.hex(64)

  def db
    return @db if @db
    @db = SQLite3::Database.new(DB_PATH)
    @db.results_as_hash = true
    @db
  end

  get '/' do
    @products = db.execute('SELECT * FROM products ORDER BY id DESC')
    erb :index
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    username = params['username']
    password = params['password']

    if username == 'admin' && password == '1234'
      session[:logged_in] = true
      redirect '/admin'
    else
      @error = 'Fel användarnamn eller lösenord.'
      erb :login
    end
  end

  post '/logout' do
    session.clear
    redirect '/'
  end

  get '/admin' do
    redirect '/login' unless session[:logged_in]

    @products = db.execute('SELECT * FROM products ORDER BY id DESC')
    erb :admin
  end

  get '/products/new' do
    redirect '/login' unless session[:logged_in]
    erb :new
  end

  post '/products' do
    redirect '/login' unless session[:logged_in]

    db.execute(
      'INSERT INTO products (name, category, price, description) VALUES (?, ?, ?, ?)',
      [params['name'], params['category'], params['price'], params['description']]
    )

    redirect '/admin'
  end

  get '/products/:id' do |id|
    @product = db.execute('SELECT * FROM products WHERE id = ?', id).first
    halt 404, 'Produkten finns inte.' unless @product
    erb :show
  end

  post '/products/:id/delete' do |id|
    redirect '/login' unless session[:logged_in]
    db.execute('DELETE FROM products WHERE id = ?', id)
    redirect '/admin'
  end
end
