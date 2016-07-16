#
# Install Ruby
#

RUN apt-get -qq clean && \
    apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends \
        software-properties-common \
    && \
    apt-get -qq clean

RUN apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y \
      ruby2.2-dev \
    && \
    apt-get clean && \
    \
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    curl -L https://get.rvm.io | /bin/bash -s stable && \
    echo 'source /etc/profile.d/rvm.sh' >> /etc/profile && \
    /bin/bash -l -c "rvm requirements" && \
    /bin/bash -l -c "rvm install 2.2.3" && \
    /bin/bash -l -c "rvm use --default 2.2.3" && \
    /bin/bash -l -c "gem install bundler" && \
    /bin/bash -l -c "rvm cleanup all"
