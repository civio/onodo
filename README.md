Onodo
=============

**[Waffle](https://waffle.io/civio/onodo)**

### Stack

* Ruby 2.4.1
* Rails 4.2.x
* Backbone.js 1.2.2
* D3.js 4.x
* Handsontable
* Webpack 2.x
* PostgreSQL 9.x
* Imagemagick 6.x

### Installation instructions

Postgres is used for the database. We use the `hstore` datatypes, so 9.0 is required. If developing in OS X [Postgres.app](http://postgresapp.com) is the easiest way to get Postgres installed. Then create a user `onodo` and the database:
 
    $ createuser -s -h localhost onodo
    $ createdb -O onodo -h localhost onodo_development
    $ createdb -O onodo -h localhost onodo_test

Then install and run locally, get a copy of the code, install the dependencies:

    $ bundle install
    $ npm install -g webpack
    $ npm install

If there's any problem installing `nokogiri` dependency in Mac OS try to run `xcode-select --install` (as explained [here](http://stackoverflow.com/questions/40038953/installing-nokogiri-on-mac-os-sierra-10-12))

Set up the database:

    $ bundle exec rake db:setup

And then run the application:

    $ bundle exec foreman start -f Procfile.dev

### Network analysis installation

The network analysis is done by a separate module, implemented in Python using the [igraph][1] library. In order to test this functionality, make sure you have Python installed, and add the bindings to igraph:

    $ pip install python-igraph

Note: there are [Ruby bindings][2] for igraph, but they haven't been updated in years.

[1]: http://igraph.org
[2]: https://github.com/alexgutteridge/igraph

### Purge & Update DB with seed file

    $ bundle exec rake db:purge db:create db:migrate db:seed
