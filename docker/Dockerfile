FROM ruby:2.3.3

RUN apt-get update && apt-get install -y

WORKDIR /usr/src/app

COPY Gemfile ./
COPY Gemfile.lock ./

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
RUN /bin/bash -c "source ~/.bashrc;nvm install 11.1.0"

RUN /bin/bash -c bundle install --without production test
