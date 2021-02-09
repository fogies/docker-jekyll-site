#
# This file compiled from Dockerfile.in.
#

FROM ubuntu:18.04

#
# 2/9/21 Add a VERSION file as part of preparing for future scripts
#
ADD VERSION .

#
# Environment configurations to get everything to play well
#

# Unicode command line
ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

# Use bash instead of sh, fix stdin tty messages
RUN rm /bin/sh && ln -s /bin/bash /bin/sh && \
    sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile
#
# Install the packages we need for getting things done
#
# Based on: https://hub.docker.com/_/buildpack-deps/
#

RUN apt-get -qq clean && \
    apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends \
        # From jessie-curl
        # https://github.com/docker-library/buildpack-deps/blob/a0a59c61102e8b079d568db69368fb89421f75f2/jessie/curl/Dockerfile
		ca-certificates \
		curl \
		wget \

        # From jessie-scm
        # https://github.com/docker-library/buildpack-deps/blob/1845b3f918f69b4c97912b0d4d68a5658458e84f/jessie/scm/Dockerfile
		bzr \
		git \
		mercurial \
		openssh-client \
		subversion \
		procps \

        # From jessie
        # https://github.com/docker-library/buildpack-deps/blob/e7534be05255522954f50542ebf9c5f06485838d/jessie/Dockerfile
		autoconf \
		automake \
		bzip2 \
		file \
		g++ \
		gcc \
		imagemagick \
		libbz2-dev \
		libc6-dev \
		libcurl4-openssl-dev \
		libdb-dev \
		libevent-dev \
		libffi-dev \
		libgeoip-dev \
		libglib2.0-dev \
		libjpeg-dev \
		liblzma-dev \
		libmagickcore-dev \
		libmagickwand-dev \
		libmysqlclient-dev \
		libncurses-dev \
		libpng-dev \
		libpq-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libtool \
		libwebp-dev \
		libxml2-dev \
		libxslt-dev \
		libyaml-dev \
		make \
		patch \
		xz-utils \
		zlib1g-dev \

        # Our common dependencies
        dos2unix \
    && \
    apt-get -qq clean
#
# Install Python
#
# Uses pyenv.
#

ENV PYTHON_VERSION 3.6.6
ENV PYTHON_PIP_VERSION 18.0

# Remove Debian python
RUN apt-get -qq purge -y python.*

# Install pyenv
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN set -ex \
    && curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash \
    && pyenv update \
    && pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION \
    && pyenv rehash

RUN set -ex \
    && python -m pip install --upgrade pip==$PYTHON_PIP_VERSION
#
# Install Ruby
#

RUN wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz && \
    mkdir /usr/src/ruby-install && \
    tar -xzC /usr/src/ruby-install --strip-components=1 -f ruby-install-0.7.0.tar.gz && \
    rm ruby-install-0.7.0.tar.gz && \
    cd /usr/src/ruby-install && \
    make install && \
    rm -rf /usr/src/ruby-install

RUN wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz && \
    mkdir /usr/src/chruby && \
    tar -xzC /usr/src/chruby --strip-components=1 -f chruby-0.3.9.tar.gz && \
    rm chruby-0.3.9.tar.gz && \
    cd /usr/src/chruby && \
    make install && \
    rm -rf /usr/src/chruby

# Pre-install of Ruby 2.5.1 with Bundler 1.16.5
RUN apt-get -qq clean && \
    apt-get -qq update && \
    ruby-install --system --no-reinstall ruby 2.5.1 && \
    gem install bundler --version "1.16.5"

# Removed for incompatibility with older OpenSSL
# # Legacy pre-install of Ruby 2.3.3 with Bundler 1.13.6
# RUN ruby-install --no-reinstall ruby 2.3.3 && \
#     source /usr/local/share/chruby/chruby.sh && \
#     chruby ruby-2.3.3 && \
#     gem install bundler --version "1.13.6"
#
# Install Node.js
#
# Based on:  https://hub.docker.com/_/node/
#

ENV NODE_VERSION 8.12.0

################################################################################
# On 12/20/16, experiencing issues with keyservers. Signature check disabled.
################################################################################

# GPG keys listed at https://github.com/nodejs/node
# RUN set -ex && \
#     for key in \
#       9554F04D7259F04124DE6B476D5A82AC7E37093B \
#       94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
#       0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
#       FD3A5288F042B6850C66B31F09FE44734EB7990E \
#       71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
#       DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
#       B9AE9905FFD7803F25714661B63B535A4C206CA9 \
#       C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
#     ; do \
#       gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
#       gpg --keyserver pgp.mit.edu:80 --recv-keys "$key" \
#     ; \
#     done

ENV NPM_CONFIG_LOGLEVEL info

################################################################################
# On 12/20/16, experiencing issues with keyservers. Signature check disabled.
################################################################################

# RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" && \
#     curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" && \
#     gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc && \
#     grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - && \
#     tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 && \
#     rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" && \
    tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-x64.tar.xz"

################################################################################
# Additional packages we need.
################################################################################
RUN apt-get -qq clean && \
    apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends \
        gawk \
        rsync \
        sshpass \
    && \
    apt-get -qq clean

################################################################################
# Install Python packages into temp directory, so they are in cache.
################################################################################
COPY docker_jekyll_site/requirements3.txt /docker_jekyll_site_temp/requirements3.txt
RUN dos2unix /docker_jekyll_site_temp/requirements3.txt && \
    pip install -r /docker_jekyll_site_temp/requirements3.txt

################################################################################
# Install Ruby gems into temp directory, so they are in cache.
################################################################################
COPY docker_jekyll_site/Gemfile /docker_jekyll_site_temp/Gemfile
COPY docker_jekyll_site/Gemfile.lock /docker_jekyll_site_temp/Gemfile.lock
RUN dos2unix /docker_jekyll_site_temp/Gemfile && \
    dos2unix /docker_jekyll_site_temp/Gemfile.lock && \
    cd /docker_jekyll_site_temp && \
    bundle install

################################################################################
# Install Node modules into temp directory, so they are in cache.
################################################################################
COPY docker_jekyll_site/npm-shrinkwrap.json /docker_jekyll_site_temp/npm-shrinkwrap.json
COPY docker_jekyll_site/package.json /docker_jekyll_site_temp/package.json
RUN dos2unix /docker_jekyll_site_temp/npm-shrinkwrap.json && \
    dos2unix /docker_jekyll_site_temp/package.json && \
    cd /docker_jekyll_site_temp && \
    npm install

################################################################################
# Expose any ports or persistent volumes.
################################################################################

# Port where we serve the files
EXPOSE 4000

# Volume where the site will persist
VOLUME ["/docker_jekyll_site/site"]

################################################################################
# Set up our entrypoint script.
################################################################################
COPY docker_jekyll_site/docker_jekyll_site_entrypoint.sh /docker_jekyll_site_entrypoint.sh
RUN dos2unix /docker_jekyll_site_entrypoint.sh && \
    chmod +x /docker_jekyll_site_entrypoint.sh

# Run the wrapper script
CMD ["/docker_jekyll_site_entrypoint.sh"]
