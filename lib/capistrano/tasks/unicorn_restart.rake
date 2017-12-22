namespace :unicorn do
  desc "Restart application server"
  task :restart do
    on roles(fetch(:unicorn_roles)) do
      execute :service, 'onodo', 'restart'
    end
  end
end

before 'deploy:finished', 'unicorn:restart'

namespace :load do
  task :defaults do
    set :unicorn_roles, fetch(:unicorn_roles, [:app])
  end
end
