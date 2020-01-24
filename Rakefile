require_relative 'config/environment'
require 'sinatra/activerecord/rake'
# require_relative 'db/seeds' <--- This will cause "rake console" to run the
# db/seeds.rb file everytime we execute "rake console"

desc 'starts a console'
task :console do
  # ActiveRecord::Base.logger = Logger.new(STDOUT)
  Pry.start
end
