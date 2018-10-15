ARG appdir=/srv/onodo

FROM ruby:2.4.3-slim

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
           build-essential \
           curl \
           git \
           gnupg \
           libpq-dev \
           libpython2.7-dev \
           libxml2-dev \
           python-pip \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
           nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN pip install python-igraph

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

ARG appdir
WORKDIR $appdir

COPY Gemfile Gemfile.lock $appdir/
RUN bundle install

COPY package.json package-lock.json Gruntfile.js rollup-entry.js rollup.config.js $appdir/
RUN mkdir -p $appdir/app/frontend/javascripts/dist
RUN npm install --unsafe-perm

COPY . $appdir
RUN DB_ADAPTER=nulldb bundle exec rake webpack:compile
RUN DB_ADAPTER=nulldb bundle exec rake assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "unicorn", "-c", "config/unicorn.rb"]
