FROM ruby:2.3.3

RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y tmux vim nodejs

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install
