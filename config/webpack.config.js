// Webpack configuration with asset fingerprinting in production.
'use strict';

var path = require('path');
var webpack = require('webpack');
var StatsPlugin = require('stats-webpack-plugin');

// must match those in config.webpack.dev_server namespace (see config/environments/development.rb)
var devServerHost = '0.0.0.0';
var devServerPort = 3080;

// set TARGET=production on the environment to add asset fingerprints
var production = process.env.TARGET === 'production';

var config = {
  entry: {
    'app-visualization':        './app/frontend/javascripts/app-visualization.js',
    'app-visualization-edit':   './app/frontend/javascripts/app-visualization-edit.js',
    'app-visualization-demo':   './app/frontend/javascripts/app-visualization-demo.js',
    'app-visualization-embed':  './app/frontend/javascripts/app-visualization-embed.js',
    'app-story':                './app/frontend/javascripts/app-story.js',
    'app-story-edit':           './app/frontend/javascripts/app-story-edit.js',
    'app-story-chapter':        './app/frontend/javascripts/app-story-chapter.js',
    'app-text-editor':          './app/frontend/javascripts/app-text-editor.js',
    'app-date-editor':          './app/frontend/javascripts/app-date-editor.js',
    'app-upload':               './app/frontend/javascripts/app-upload.js'
  },

  output: {
    // Build assets directly into public/webpack/, let webpack know
    // that all webpacked assets start with webpack/

    // must match config.webpack.output_dir
    path: path.join(__dirname, '..', 'public', 'webpack'),
    publicPath: '/webpack/',

    filename: production ? '[name]-bundle-[chunkhash].js' : '[name]-bundle.js',
    sourceMapFilename: "[name]-bundle.js.map"
  },

  resolve: {
    modules: [
      path.join(__dirname, '..', 'app','frontend','javascripts'),
      'node_modules'
    ],
    extensions: ['.coffee', '.js'],
    alias: {
      'handlebars': 'handlebars/runtime.js'
    }
  },

  module: {
    rules: [{
      test: /\.coffee$/,
      use: [{
        loader: 'coffee-loader'
      }]
    }, {
      test: /\.handlebars$/,
      use: [{
        loader: 'handlebars-loader'
      }]
    }]
  },

  plugins: [
    // must match config.webpack.manifest_filename
    new StatsPlugin('manifest.json', {
      // We only need assetsByChunkName
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true
    })
  ],

  externals: {
    // require("jquery") is external (from jquery-rails gem) & available on the global var jQuery
    "jquery": "jQuery"
  }
};

if (production) {
  config.plugins.push(
    new webpack.NoEmitOnErrorsPlugin(),
    new webpack.optimize.UglifyJsPlugin({
      compressor: { warnings: false },
      sourceMap: false
    }),
    new webpack.DefinePlugin({
      'process.env': { NODE_ENV: JSON.stringify('production') }
    }),
    new webpack.optimize.OccurrenceOrderPlugin()
  );
} else {
  config.devServer = {
    port: devServerPort,
    headers: { 'Access-Control-Allow-Origin': '*' }
  };
  config.output.publicPath = '//' + devServerHost + ':' + devServerPort + '/webpack/';
  // Source maps
  config.devtool = 'cheap-module-eval-source-map';
}

module.exports = config;
