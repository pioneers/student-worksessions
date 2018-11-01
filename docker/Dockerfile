FROM ruby:2.3.3

RUN apt-get update
RUN apt-get install -y nodejs tmux vim

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install
