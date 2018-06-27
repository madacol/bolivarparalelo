require './main'
require 'sass/plugin/rack'
use Sass::Plugin::Rack
run Sinatra::Application