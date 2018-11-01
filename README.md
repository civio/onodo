Onodo
=============

**[Waffle](https://waffle.io/civio/onodo)**

### Stack

* Ruby 2.4.3
* Rails 4.2.x
* Backbone.js 1.2.2
* D3.js 4.x
* Handsontable
* Webpack 2.x
* PostgreSQL 9.x
* Imagemagick 6.x

### Development environment

Postgres is used for the database. We use the `hstore` datatypes, so 9.0 is required. If developing natively in OS X [Postgres.app](http://postgresapp.com) is the easiest way to get Postgres up and running, but by using the provided [Docker](https://www.docker.com/) configuration it can be conveniently ignored.

To install and run locally without Docker, once you've got a copy of the code from the [GitHub repository](https://github.com/civio/onodo), install the dependencies:

    $ bundle install
    $ npm install

Set up the database:

    $ bundle exec rake db:create db:migrate db:seed

And then run the application:

    $ bundle exec foreman start -f Procfile.dev

If using Docker, make sure to build the image first:

    $ docker-compose build

Then set up the database:

    $ docker-compose run --rm onodo bundle exec rake db:create db:migrate db:seed

And finally start the application:

    $ docker-compose up

To access the running application go to your browser and visit http://localhost:3000.

In development mode, any changes made in the source code (except for initializers and some other init stuff) will be automatically reloaded by Rails.

If you're using Docker and you fancy opening a shell into the running container to execute anything locally, you can do it by issuing:

    $ docker compose exec onodo bash

### Network analysis installation

The network analysis is done by a separate module, implemented in Python using the [igraph][1] library. If you're developing natively, make sure you have Python installed, and add the bindings to igraph:

    $ pip install python-igraph

If you're developing using the provided provided Docker configuration everithing is already set up for you.

Note: there are [Ruby bindings][2] for igraph, but they haven't been updated in years.

[1]: http://igraph.org
[2]: https://github.com/alexgutteridge/igraph

### Purge & update DB with seed file

Use the following instruction to reset the database if developing natively:

    $ bundle exec rake db:purge db:create db:migrate db:seed

Or this one if using Docker:

    $ docker compose run --rm onodo bundle exec rake db:purge db:create db:migrate db:seed
