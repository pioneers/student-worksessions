FROM ruby:2.3.3

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install
RUN apt update
RUN apt install -y nodejs
