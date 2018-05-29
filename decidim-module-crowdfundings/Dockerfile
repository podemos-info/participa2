FROM ruby:2.4.2

# Required packages
RUN apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get install -y build-essential \
                       postgresql-client \
                       libpq-dev \
                       imagemagick \
                       libmagickwand-dev \
                       curl \
                       locales \
                       sudo && \
    apt-get clean

# NODE JS
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash && \
    apt-get update -qq && \
    apt-get install nodejs


# PhantomJS
ENV PHANTOM_JS_VERSION 2.1.1
RUN curl -L -O https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOM_JS_VERSION-linux-x86_64.tar.bz2 && \
    tar xvjf phantomjs-$PHANTOM_JS_VERSION-linux-x86_64.tar.bz2 && \
    mv phantomjs-$PHANTOM_JS_VERSION-linux-x86_64 /usr/local/share && \
    ln -sf /usr/local/share/phantomjs-$PHANTOM_JS_VERSION-linux-x86_64/bin/phantomjs /usr/local/bin && \
    mkdir -p /root/.phantomjs/$PHANTOM_JS_VERSION/x86_64-linux/bin && \
    ln -sf /usr/local/share/phantomjs-$PHANTOM_JS_VERSION-linux-x86_64/bin/phantomjs /root/.phantomjs/$PHANTOM_JS_VERSION/x86_64-linux/bin/phantomjs && \
    rm phantomjs-$PHANTOM_JS_VERSION-linux-x86_64.tar.bz2


# Define where our application will live inside the image
ENV RAILS_ROOT /decidim-collaborations
RUN mkdir -p $RAILS_ROOT

ENV BUNDLE_PATH /gems
ENV GEM_HOME_BASE=$BUNDLE_PATH
ENV GEM_HOME=$BUNDLE_PATH

RUN mkdir -p $BUNDLE_PATH

# Locale generation
RUN locale-gen --purge en_US.UTF-8 && \
    echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale

###### USER CREATION #########
# Change the Group ID and User ID with your local Group and user id
ENV USER_NAME aspgems
ENV USER_ID 1000
ENV GROUP_ID 1000
ENV USER_HOME /home/$USER_NAME
RUN groupadd $USER_NAME -g $GROUP_ID && \
    useradd $USER_NAME -d $USER_HOME -m -s /bin/bash --uid $USER_ID --gid $GROUP_ID && \
    adduser $USER_NAME sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL !requiretty' >> /etc/sudoers

RUN chown -R aspgems:aspgems $RAILS_ROOT
RUN chown -R aspgems:aspgems $BUNDLE_PATH

WORKDIR $RAILS_ROOT

ADD . $RAILS_ROOT

USER aspgems

# Bundle configuration
RUN gem install bundler

ENV BUNDLE_JOBS=4
RUN bundle check || bundle install


