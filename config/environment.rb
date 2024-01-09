require 'bundler'
APP_ROOT = File.expand_path('..', File.dirname(__FILE__))
$LOAD_PATH << File.join(APP_ROOT, 'lib')
$LOAD_PATH << APP_ROOT
ENV['TZ'] = 'UTC'
ENV['RACK_ENV'] ||= 'development'
require 'oj'
require 'mongo'

Oj.mimic_JSON # Overtake JSON.parse and JSON.generate
MDB = Mongo::Client.new ENV['MONGO_URL']
