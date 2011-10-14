set :node_env, "staging"
set :branch, "master"
set :application_port, "1603"
set :deploy_to, "/srv/www/apps/#{application}/#{node_env}"