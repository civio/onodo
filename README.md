Onodo
=============

### Stack
* Rails 4.2
* React.js
* Backbone
* Webpack for js management
* PostgreSQL

### Installation instructions

    $ bundle install
    $ npm install -g webpack
    $ npm install
    $ rake db:setup
    $ foreman start -f Procfile.dev

### Purge & Update DB with seed file

    $ rake db:purge db:create db:migrate db:seed

**[Waffle](https://waffle.io/civio/onodo)**