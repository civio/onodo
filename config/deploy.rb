# config valid only for current version of Capistrano
lock '3.8.0'

set :application, 'onodo'
set :repo_url, 'git@github.com:civio/onodo.git'

set :linked_dirs, fetch(:linked_dirs, []).push('public/uploads', 'node_modules')

before 'deploy:reverted', 'npm:install'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# namespace :deploy do
#
#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#     end
#   end
#
# end

# Bundler specific options, introduced by 'capistrano-bundler' via 'capistrano-rails'
#
# set :bundle_roles, :all                                         # this is default
# set :bundle_servers, -> { release_roles(fetch(:bundle_roles)) } # this is default
# set :bundle_binstubs, -> { shared_path.join('bin') }            # default: nil
# set :bundle_gemfile, -> { release_path.join('MyGemfile') }      # default: nil
# set :bundle_path, -> { shared_path.join('bundle') }             # this is default
# set :bundle_without, %w{development test}.join(' ')             # this is default
# set :bundle_flags, '--deployment --quiet'                       # this is default
# set :bundle_env_variables, {}                                   # this is default

# Rails specific options, introduced by 'capistrano-rails'
#
# If the environment differs from the stage name
# set :rails_env, 'staging'
#
# Defaults to 'db'
# set :migration_role, 'migrator'
#
# Defaults to false
# Skip migration if files in db/migrate were not modified
# set :conditionally_migrate, true
#
# Defaults to [:web]
# set :assets_roles, [:web, :app]
#
# Defaults to 'assets'
# This should match config.assets.prefix in your rails config/application.rb
# set :assets_prefix, 'prepackaged-assets'
#
# If you need to touch public/images, public/javascripts, and public/stylesheets on each deploy
# set :normalize_asset_timestamps, %w{public/images public/javascripts public/stylesheets}
#
# Defaults to nil (no asset cleanup is performed)
# If you use Rails 4+ and you'd like to clean up old assets after each deploy,
# set this to the number of versions to keep
# set :keep_assets, 2
#
# Defaults to the primary :db server
# set :migration_role, :db
# set :migration_servers, -> { primary(fetch(:migration_role)) }
