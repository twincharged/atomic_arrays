require "bundler/gem_tasks"
require "rubygems"
require "bundler/setup"

require "pg"
require "active_record"
require "yaml"
require 'rspec/core/rake_task'

namespace :db do

  desc "Migrate the db"
  task :migrate do
    connection_details = YAML.load_file(File.expand_path("../spec/db/database.yml", __FILE__))["test"]
    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::Migrator.migrate("spec/db/")
  end


  desc "Create the db"
  task :create do
    connection_details = YAML.load_file(File.expand_path("../spec/db/database.yml", __FILE__))["test"]
    ActiveRecord::Base.establish_connection(connection_details.merge({'database' => 'postgres', 'schema_search_path' => 'public'}))
    ActiveRecord::Base.connection.create_database(connection_details.fetch('database'))
  end

  desc "drop the db"
  task :drop do
    connection_details = YAML.load_file(File.expand_path("../spec/db/database.yml", __FILE__))["test"]
    ActiveRecord::Base.establish_connection(connection_details.merge({'database' => 'postgres', 'schema_search_path' => 'public'}))
    ActiveRecord::Base.connection.drop_database(connection_details.fetch('database'))
  end
end

RSpec::Core::RakeTask.new(:spec)
Dir.glob('tasks/**/*.rake').each(&method(:import))

task default: :spec