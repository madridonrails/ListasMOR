set :application, "listasgem"
set :repository,  "http://larry2.aspgems.com/repos/ASPgems/listasgem/trunk"

set :deploy_to, "/home/demos/rails_applications/#{application}/#{stage}"
set :rails_env, "development"
set :user, "demos"

# It make a cached copy in shared/svn_trunk_cache. Subsequent deployments will just do an svn update on that directory instead a checkout every time.
set :deploy_via, :remote_cache
set :repository_cache, "svn_repository_cache" 

# Subversion access data variables
set(:scm_username) do
  Capistrano::CLI.ui.ask "Give me a svn user: "
end
set(:scm_password) do
  Capistrano::CLI.ui.ask "Give me a svn password for user #{scm_username}: "
end

# Database access data variables
set :database_server, "localhost"
set :database_username, "listasgem"
set(:database_password) do
  Capistrano::CLI.ui.ask "Give me a database password for user #{database_username}: "
end

# Mongrel configuration variables
set :mongrel_port, 8002
set :mongrel_servers, 1
set :mongrel_username, user  # Change if user is diffent to shell user
set :mongrel_group, user     # Change if group is different to shell group


# Roles for hosts separated by commas
role :app, "larry.aspgems.com"    # Rails app is hosted here and dynamic content is served here
role :web, "larry.aspgems.com"    # Webserver is hosted here
role :db,  "larry.aspgems.com", :primary => true # Database is hosted here, primary it's an attribute(read capistrano manual)


# namespace :deploy do
#   desc "Modified restart task for work ONLY with mongrel"
#   task :restart do
#     #run "cd #{deploy_to}/current && mongrel_rails restart"
#     stop
#     start
#   end
#   desc "Modified start task for work ONLY with mongrel"
#   task :start do
#     run "cd #{deploy_to}/current && mongrel_rails start -d -p #{mongrel_port}"
#   end
#   desc "Modified stop task for work ONLY with mongrel"
#   task :stop do
#     run "cd #{deploy_to}/current && mongrel_rails stop"
#   end
# 
#   namespace :config_files do
#     desc "Create mongrel_cluster yaml in shared path" 
#     task :mongrel_cluster_yml do
#       puts "*** Task rewrite: Not needed mongrel_cluster.yml in #{stage}"
#     end
# 
#     desc "Make symlink for mongrel_cluster yaml" 
#     task :symlink_mongrel_cluster_yml do
#       puts "*** Task rewrited: Not needed link to mongrel_cluster.yml in #{stage}"
#     end
#   end
# 
# 
# end
