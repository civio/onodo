namespace :bundler do
  desc "Lock and cache the gems in the current Bundler environment"
  task :package do
    on fetch(:bundle_servers) do
      within release_path do
        with fetch(:bundle_env_variables, {}) do
          options = []
					options << "--gemfile #{fetch(:bundle_gemfile)}" if fetch(:bundle_gemfile)
          options << "--no-prune" if fetch(:bundle_cache_noprune)
          options << "--all" if fetch(:bundle_cache_all)
          options << "--path #{fetch(:bundle_path)}" if fetch(:bundle_path)
          options << "#{fetch(:bundle_package_flags)}" if fetch(:bundle_package_flags)

          execute :bundle, :package, *options

          set :bundle_flags, fetch(:bundle_flags, "") << " --local"
        end
      end
    end
  end

  before 'bundler:install', 'bundler:package'
end

namespace :load do
  task :defaults do
    set :bundle_cache_all, true
    set :bundle_cache_noprune, false
    set :bundle_package_flags, '--quiet'
  end
end
