FROM ruby:2.2.3

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

COPY package.json /myapp/package.json
RUN npm install -g webpack
RUN npm install

RUN ls /myapp
COPY . /myapp
RUN cat /myapp/config/database.yml