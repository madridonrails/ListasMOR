namespace :todogem do
  INITIALIZABLE_TABLES=['user']
  
  desc "initialize db contents (initial load of master tables)"
  task :initialize_contents => :environment do |t|
    puts "please confirm you want to initialize contents  (type 'yes' to confirm, 'ask' to select each content or anything else to skip)"
    s_answer=$stdin.gets
    if s_answer.chomp == 'yes'
      init_all
    elsif s_answer.chomp == 'ask'
      init_asking
    else
      puts 'initialize_contents skipped'
     end
  end #task do
  
  desc "reloads language files in all ports of this server"
  task :local_text_reload => :environment do |t|
    LocalText.listening_ports.each do |port|
     puts "reloading languages in port #{port}"
     begin
      puts(Net::HTTP.get('localhost','/local_text/reload_config_files',port))
     rescue Exception => e
      puts e.message
     end
    end 
  end #local_text_reload
  
  def init_all
    INITIALIZABLE_TABLES.each do |model|      
      self.send("init_#{model}")
      puts "#{model} initialized"    
    end    
  end

  def init_asking
    INITIALIZABLE_TABLES.each do |model|
      puts "please confirm you want to initialize #{model}  (type 'yes' to confirm or anything else to skip)"
      s_answer=$stdin.gets
      if s_answer.chomp == 'yes'
        self.send("init_#{model}")
        puts "#{model} initialized"
      else
        puts "init_#{model} skipped"
       end
     end
  end

  def init_user
    u=User.find_or_initialize_by_email 'admin@listasgem.com'
    u.email='admin@listasgem.com'
    u.email_confirmation='admin@listasgem.com'
    u.password='L1stasG3m'
    u.password_confirmation='L1stasG3m'
    u.first_name='admin'
    u.last_name='listasgem'
    u.is_admin=true
    u.save(false)
  end

    
end #namespace

