require 'sinatra'
require 'redis'
require 'base64'
require 'digest/md5'

redis = Redis.new

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def shorten(url)
      Base64.urlsafe_encode64([Digest::MD5.hexdigest(url).to_i(16)].pack("N")).sub(/==\n?$/, '')
  end
end

get '/' do
  erb :index
end

post '/' do
  if params[:url] and not params[:url].empty?
    @shortcode = shorten params[:url]
    redis.setnx "links:#{@shortcode}", params[:url]
  end
  erb :index
end

get '/:shortcode' do
  @url = redis.get "links:#{params[:shortcode]}"
  redirect @url || '/'
end
