# DOCKER_VERSION 0.9.0
# VERSION 0.1.0

FROM edpaget/passenger:latest
MAINTAINER Edward Paget <ed@zooniverse.org>

RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q install build-essential ruby1.9.1 ruby1.9.1-dev libsqlite3-dev libcurl3 libxml2 libxslt1-dev libcurl4-gnutls-dev git-core

RUN gem install bundler
WORKDIR /rails
ADD Gemfile /rails/Gemfile
ADD Gemfile.lock /rails/Gemfile.lock
ADD /vendor/ /rails/vendor
RUN bundle install --without development test

ADD ./ /rails

WORKDIR /
VOLUME ["/rails/log"]

ENV RACK_ENV production
ENV RAILS_ENV production
ENV VIRTUAL_ENV setilive.org

ADD docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
