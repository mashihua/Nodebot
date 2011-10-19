##
# Capistrano tasks for Ubantu.
#
# Author: Shihua Ma http://f2eskills.com/

set :stages, %w[staging production]
set :default_stage, 'staging'
require 'capistrano/ext/multistage'
#application name
set :application, "example"
#start server script
set :node_file, "app.js"
#deploy host
set :host, "hostname"
#user name,must be a sudoer without prompting for password 
set :user, "username"
set :admin_runner, user
#set Monit web interface admin's pwd
set :monit_pwd, "monit"

set :repository, "git@git@github.com:mashihua/Nodebot.git"
set :scm, :git
set :deploy_via, :remote_cache
role :app, host
set :use_sudo, true


namespace :deploy do
  
  desc "Start node server"
  task :start, :roles => :app, :except => { :no_release => true } do
    sudo "start #{application}_#{node_env}"
  end
  
  desc "Stop node server"
  task :stop, :roles => :app, :except => { :no_release => true } do
    sudo "stop #{application}_#{node_env}"
  end
  
  desc "Restart node server"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "sudo restart #{application}_#{node_env} || sudo start #{application}_#{node_env}"
  end

  desc "Check required packages and install if packages are not installed"
  task :check_packages, roles => :app do
    run "cd #{release_path} && jake depends"
  end

  task :create_deploy_to_with_sudo, :roles => :app do
    sudo "mkdir -p #{deploy_to} && chown #{admin_runner}:#{admin_runner} #{deploy_to}"
  end

  desc "Update submodules"
  task :update_submodules, :roles => :app do
    run "cd #{release_path}; git submodule init && git submodule update"
  end
  
  task :write_upstart_script, :roles => :app do
    upstart_script = <<-UPSTART
description "#{application}"

start on startup
stop on shutdown

script
# We found $HOME is needed. Without it, we ran into problems
export HOME="/home/#{admin_runner}"
export NODE_ENV="#{node_env}"

cd #{current_path}
exec sudo -u #{admin_runner} sh -c "NODE_ENV=#{node_env} /usr/local/bin/node #{current_path}/#{node_file} #{application_port} >> #{shared_path}/log/#{node_env}.log 2>&1"
end script
respawn
UPSTART
    put upstart_script, "/tmp/#{application}_upstart.conf"
      sudo "mv /tmp/#{application}_upstart.conf /etc/init/#{application}_#{node_env}.conf"
    end
  end
  
  task :write_monit_script, :roles => :app do
    #Monit script for application 
    monit_script = <<-MONIT
#!monit
check host #{application}_#{node_env} with address 127.0.0.1
  start program = "start #{application}_#{node_env}"
  stop program  = "stop #{application}_#{node_env}"
  if failed port #{application_port} protocol HTTP
    request /
    with timeout 10 seconds
    then restart
MONIT
    put monit_script, "/tmp/#{application}_#{node_env}_monit"
    sudo "mv /tmp/#{application}_#{node_env}_monit /etc/monit/conf.d/#{application}_#{node_env}_monit"
  end
  
end

before 'deploy:setup', 'deploy:create_deploy_to_with_sudo'
after 'deploy:setup', 'deploy:write_upstart_script'
after "deploy:finalize_update", "deploy:update_submodules", "deploy:check_packages"

