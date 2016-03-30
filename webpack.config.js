// Webpack config file
// Read more: http://clarkdave.net/2015/01/how-to-use-webpack-with-rails/

var path = require('path');
var webpack = require('webpack');

var config = module.exports = {
  // the base path which will be used to resolve entry points
  context: __dirname,
  // the main entry point for our application's frontend JS
  entry: {
    "app": "./app/frontend/javascripts/app.js",
    //application:  "./app/frontend/javascripts/application.cjsx",
  },
  output: {
    // this is our app/assets/javascripts directory, which is part of the Sprockets pipeline
    path: path.join(__dirname, 'app', 'assets', 'javascripts'),
    // the filename of the compiled bundle, e.g. app/assets/javascripts/bundle.js
    filename: "[name]-bundle.js",
    // if the webpack code-splitting feature is enabled, this is the path it'll use to download bundles
    publicPath: "/assets",
    // Make 'virtual’ source files appear under the domain > assets directory in the Sources tab of Chrome Inspector 
    // http://clarkdave.net/2015/01/how-to-use-webpack-with-rails/#virtual-source-path
    devtoolModuleFilenameTemplate: '[resourcePath]',
    devtoolFallbackModuleFilenameTemplate: '[resourcePath]?[hash]'
  },
  resolve: {
    // tell webpack which extensions to auto search when it resolves modules. With this,
    // you'll be able to do `require('./utils')` instead of `require('./utils.js')`
    extensions: ["", ".coffee", ".js"],
    // We only need to look into `node_modules` folder
    modulesDirectories: ["node_modules"],
    // Avoid Handebars warning require.extentions not supported using Handebars runtime build
    // https://github.com/wycats/handlebars.js/issues/953
    alias: {
      'handlebars': 'handlebars/runtime.js'
    }
  },
  resolveLoader: {
    // Avoid Handebars warning require.extentions not supported
    // https://github.com/wycats/handlebars.js/issues/953
    alias: {
      'hbs': 'handlebars-loader'
    }
  },
  module: {
    loaders: [
      { test: /\.coffee$/,      loader: "coffee-loader"},
      { test: /\.handlebars$/,  loader: "handlebars-loader" }
    ]
  },
  /*
  plugins: [
    new webpack.ResolverPlugin(
      new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin(".bower.json", ["main"])
    )
    /*
    new webpack.ProvidePlugin({
      'React': 'react/addons',
      //'react-faux-dom': 'react-d3-core/react-faux-dom', //'react-d3-core/react-faux-dom',
      //'d3': 'd3',
      //$: "jquery",
      //jQuery: "jquery"
      //Backbone: 'backbone',
      //'_': 'lodash'
    }),
    //new webpack.IgnorePlugin(/^\.\/locale$/, [/moment$/]),
    // http://clarkdave.net/2015/01/how-to-use-webpack-with-rails/#a-mix-of-multiple-entry-points-and-exposing-modules
    //new webpack.optimize.CommonsChunkPlugin('common-bundle.js')
  ]
  */
};