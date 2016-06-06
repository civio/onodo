namespace :deploy do
  desc 'Compile webpack assets'
  task :compile_webpack do
    invoke 'deploy:webpack:compile'
  end

  namespace :webpack do
    task :compile do
      on release_roles(fetch(:webpack_roles)) do
        within release_path do
          with target: fetch(:webpack_target) do
            execute :webpack, "--bail --config #{fetch(:webpack_config)} 2>&1"
          end
        end
      end
    end
  end
end

before 'deploy:compile_assets', 'deploy:compile_webpack'

namespace :load do
  task :defaults do
    set :webpack_roles, fetch(:webpack_roles, [:web])
    set :webpack_prefix, fetch(:webpack_prefix, 'webpack')
    set :webpack_target, fetch(:webpack_target, 'production')
    set :webpack_config, fetch(:webpack_config, 'config/webpack.config.js')
  end
end
