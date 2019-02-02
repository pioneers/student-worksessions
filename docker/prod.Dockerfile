FROM ruby:2.3.3

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
RUN /bin/bash -c "source ~/.bashrc;nvm install 11.1.0"

WORKDIR /usr/src/app

COPY . /usr/src/app
RUN /bin/bash -c "source ~/.bashrc;bundle install --without development test"
CMD /bin/bash -c "source ~/.bashrc;bin/rails s -e production"
