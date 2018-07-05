require 'sinatra'
require 'json'

ENV['APP_DIR'] = File.expand_path(File.dirname(__FILE__))

get '/' do

  data = JSON.parse File.read("#{ENV['APP_DIR']}/tmp/prices.json")

  erb :index, :locals => {:data => data}

end
