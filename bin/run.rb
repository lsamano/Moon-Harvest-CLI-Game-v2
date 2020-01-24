require_relative '../config/environment'
ActiveRecord::Base.logger.level = 1 # Disables logging

new_cli = CommandLineInterface.new
new_cli.game_start
