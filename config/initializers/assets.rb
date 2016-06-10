# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js.js )

# Avoid Sprocket to break the source maps by appending a semi-colon to them
# http://clarkdave.net/2015/01/how-to-use-webpack-with-rails/#source-maps
# Rails.application.config.assets.configure do |env|
#     env.unregister_postprocessor 'application/javascript', Sprockets::SafetyColons
# end

Rails.application.config.assets.precompile += %w( application-embed.css )