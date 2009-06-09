# based on code from the mysql_tasks plugin
require 'erb'
require 'yaml'

def retrieve_db_info
  result = File.read "#{RAILS_ROOT}/config/database.yml"
  result.strip!
  config_file = YAML::load(ERB.new(result).result)
  return [
    config_file[RAILS_ENV]['database'],
    config_file[RAILS_ENV]['username'],
    config_file[RAILS_ENV]['password'],
    config_file[RAILS_ENV]['encoding']
  ]
end

namespace :mysql do

  # If Parameter 'drop' is present and the database exists, the database is dropped
  desc "creates the schema of the database"
  task :create_schema do
    database, user, password, encoding = retrieve_db_info
    sql_for_encoding = encoding ? "character set #{encoding}" : ''
    IO.popen("mysql -u root -p", 'w') do |pipe|
      unless ENV['drop'].nil?
        pipe.write <<-SQL
          drop database if exists #{database};
        SQL
      end  
      pipe.write <<-SQL
        create database #{database} #{sql_for_encoding};
        grant all on #{database}.* to '#{user}'@'localhost' identified by '#{password}';
      SQL
    end
    # $? is a Proccess:Status class with the result of the IO.popen process
    if $?.success?
      puts "Database #{database} dropped" unless ENV['drop'].nil? 
      puts "Database #{database} created"
    end
  end

  desc "creates the schema and runs migrations"
  task :create_database => ['create_schema', 'db:migrate'] do
    puts "Migrations executed"
  end
  
  # Parameter 'days' indicates maximum inactivity days before deletion. Default is 30
  desc "cleanup old sessions from the database"   
  task :expire_sessions => :environment do  
    
    days = ENV['days'] || 30 
    ActiveRecord::Base.connection.execute "delete from sessions where datediff(utc_date(),updated_at) > #{days}"  
    puts "Sessions idle more than #{days} days expired"
  end #task do
  
  desc "cleanup anonymous sessions from the database"   
  task :expire_anonymous_sessions => :environment do
    User #necessary for unmarshalling so we have the reference to user loaded
    days = ENV['days'] || 1
    Session.find_each(:conditions=>"datediff(utc_date(),updated_at) > #{days}" ) do |session|
      begin 
         session_data = CGI::Session::ActiveRecordStore::Session.unmarshal(session.data)
         session.destroy if session_data[:user].blank?
      rescue Exception => e
        puts "Error: " + e.message()
      end
    end
    puts "Anonymous sessions expired"
  end

end #namespace

