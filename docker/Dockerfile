FROM ruby:2.3.3

RUN apt-get update

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
RUN /bin/bash -c "source ~/.bashrc;nvm install 11.1.0"

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN /bin/bash -c bundle install
