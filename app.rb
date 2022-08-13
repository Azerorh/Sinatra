require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, {:adapter =>'sqlite3', :database=>'barbershop.db'}

class Client < ActiveRecord::Base
  validates :name,     presence: true
  validates :phone,    presence: true
  validates :datetime, presence: true
  validates :barber,   presence: true
  validates :color,    presence: true
end

class Barber < ActiveRecord::Base

end

class Post < ActiveRecord::Base
  has_many :comments, dependent: :destroy
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

before do
  @barbers = Barber.all
end

get '/' do
  @barbers = Barber.order "created_at DESC"
  erb :index
end

get '/visit' do
  @c = Client.new
  erb :visit
end

post '/visit' do
  @c = Client.new params[:client]

  if @c.save
    erb '<h2>Thanks for signing up!</h2>'  
  else
    @error = @c.errors.full_messages.first
    erb :visit
  end
end

get '/barber/:id' do
  @barber = Barber.find(params[:id])

  erb :barber
end

get '/records' do
  @clients = Client.order('created_at DESC')
  
  erb :records
end

get '/client/:id' do
  @client = Client.find(params[:id])

  erb :client
end

get '/blog' do
  @posts = Post.order('created_at DESC')

  erb :blog
end

get '/post/new' do
  @post = Post.new

  erb :new
end

post '/post/new' do
  @post = Post.new(params[:post])

  if @post.save
    redirect to :blog
  else
    @error = @post.errors.full_messages.first
    erb :new
  end
end

get '/posts/:id' do
  @post = Post.find(params[:id])
  @comments = Comment.where('post_id', params[:id])
  @comment = Comment.new

  erb :post
end

post '/:id/comment/new' do
  @post = Post.find(params[:id])
  @comment = @post.comments.new(params[:comment])

  if @comment.save
    redirect to ('/posts/' + @comment.post_id.to_s)
  else
    @error = @comment.errors.full_messages.first
    erb :post
  end
end