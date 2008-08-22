default_run_options[:pty] = true
set :application, "mubs"
# set :repository, "git@github.com:johnson/mubs.git" 
set :repository, "http://github.com/johnson/mubs.git" 
# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm, :git
# set :scm_passphrase, "p@ssw0rd" #This is your custom users password
set :user, "root"
set :branch, "master"
set :ssh_options, { :forward_agent => true }


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/webhost/#{application}"

# set :deploy_via, :remote_cache
set :git_shallow_clone, 1

role :app, "jayesoui.com"
role :web, "jayesoui.com"
role :db,  "jayesoui.com", :primary => true

# ln -s /webhost/mubs/shared/config/lighttpd.conf /webhost/mubs/current/config/lighttpd.conf
# ln -s /webhost/mubs/shared/config/database.yml /webhost/mubs/current/config/database.yml