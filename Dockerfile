FROM ubuntu:14.04

# Install the packages we need for getting things done
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      dos2unix \
      git \
    && \
    apt-get clean

# Install the packages we need for publishing
RUN apt-get update && \
    apt-get install -y \
      gawk \
      sshpass \
    && \
    apt-get clean

# Install the packages we need for Jekyll
RUN apt-get update && \
    apt-get install -y \
      node \
      python3 \
      python3-pip \
      python3.4-venv \
      ruby \
      ruby-dev \
    && \
    apt-get clean

RUN apt-get update && \
    apt-get install -y \
      git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev \
      libgdbm-dev \
      libncurses5-dev \
      automake \
      libtool \
      bison \
      libffi-dev \
    && \
    apt-get clean

RUN cd && \
    git clone git://github.com/sstephenson/rbenv.git .rbenv && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
    exec $SHELL && \
    git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build  && \
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc  && \
    exec $SHELL  && \
    git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash  && \
    rbenv install 2.2.3  && \
    rbenv global 2.2.3  && \
    ruby -v

# Port where we serve the files
EXPOSE 4000

# Volume where the site will persist
VOLUME ["/site"]

# Our wrapper script
COPY run.sh /tmp/run.sh
RUN dos2unix /tmp/run.sh
RUN chmod a+x /tmp/run.sh

# Run the wrapper script
CMD ["/tmp/run.sh"]

http://stackoverflow.com/a/9056395/497756
