set :user, 'jackx'
set :domain, 'localhost'
set :application, "depot"

# file paths
set :repository,  "#{user}@#{domain}:git/#{application}.git"
set :deploy_to, "/Users/#{user}/Sites/#{domain}"

# set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# miscellaneous options
set :deploy_via, :remote_cache
set :scm, 'git'
set :brach, 'master'
set :scm_verbose, true
set :use_sudo, false

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  desc "create asset packages for production"
  task :after_update_code, :roles => [:web] do
    run <<-EOF
      cd #{release_path} && rake asset:packager:build_all
    EOF
  end
  
  desc "cause Passenger to initiate a restart"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=production"
  end
  
  # task :stop do ; end
  # task :restart, :roles => :app, :except => { :no_release => true } do
  #   run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  # end
end

after "deploy:update_code", :bundle_install
desc "install the neccessary prerequistites"
task :bundle_install, :role => :app do
  run "cd #{release_path} && bundle install"
end