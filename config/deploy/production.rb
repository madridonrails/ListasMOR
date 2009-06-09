set :application, "listasgem"
set :repository,  "https://larry.aspgems.com:8083/repos/ASPgems/listasgem/trunk"

set :deploy_to, "/home/listasgem/ASPgems/#{application}/#{stage}"
set :rails_env, "production"
set :user, "listasgem"

# It make a cached copy in shared/svn_trunk_cache. Subsequent deployments will just do an svn update on that directory instead a checkout every time.
set :deploy_via, :remote_cache
set :repository_cache, "svn_repository_cache"
ssh_options[:config] = false
set :gateway, "monica.aspgems.com"


# Subversion access data variables
set(:scm_username) { Capistrano::CLI.ui.ask("Type your svn username: ") }
set(:scm_password) { Capistrano::CLI.password_prompt("Type your svn password for user #{scm_username}: ") }



# Database access data variables
set :database_server, "localhost"
set :database_username, "listasgem"
set(:database_password) do
  Capistrano::CLI.ui.ask "Give me a database password for user #{database_username}: "
end

# Mongrel configuration variables
set :mongrel_port, 8085
set :mongrel_servers, 2
set :mongrel_username, user  # Change if user is diffent to shell user
set :mongrel_group, user     # Change if group is different to shell group


# Roles for hosts separated by commas
role :app, "acens.aspgems.com"    # Rails app is hosted here and dynamic content is served here
role :web, "acens.aspgems.com"    # Webserver is hosted here
role :db,  "acens.aspgems.com", :primary => true # Database is hosted here, primary it's an attribute(read capistrano manual)

