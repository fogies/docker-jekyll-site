#
# This file compiled from Dockerfile.in.
#

FROM ubuntu:14.04

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
# Based on:  https://hub.docker.com/_/python/
#

ENV PYTHON_VERSION 3.5.2
ENV PYTHON_PIP_VERSION 8.1.1

# remove several traces of debian python
RUN apt-get -qq purge -y python.*

# gpg: key F73C700D: public key "Larry Hastings <larry@hastings.org>" imported
ENV GPG_KEY 97FC712E4C024BBEA48A61ED3A5CA953F73C700D

RUN set -ex \
	&& curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz \
	&& curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& rm -r "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& ./configure \
		--enable-loadable-sqlite-extensions \
		--enable-shared \
		> python.make.configure.log \
	&& make -j$(nproc) > python.make.log \
	&& make install > python.make.install.log \
	&& ldconfig \
    && curl -fSL 'https://bootstrap.pypa.io/get-pip.py' | python3 \
	&& pip install --no-cache-dir --upgrade pip==$PYTHON_PIP_VERSION \
	&& [ "$(pip list | awk -F '[ ()]+' '$1 == "pip" { print $2; exit }')" = "$PYTHON_PIP_VERSION" ] \
	&& find /usr/local -depth \
		\( \
		    \( -type d -a -name test -o -name tests \) \
		    -o \
		    \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		\) -exec rm -rf '{}' + \
	&& rm -rf /usr/src/python ~/.cache

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& rm -f easy_install && ln -s easy_install-3.5 easy_install \
	&& rm -f idle && ln -s idle3 idle \
	&& rm -f pip && ln -s pip3 pip \
	&& rm -f pydoc && ln -s pydoc3 pydoc \
	&& rm -f python && ln -s python3 python \
	&& rm -f python-config && ln -s python3-config python-config
#
# Install Ruby
#
# Based on:  https://hub.docker.com/_/ruby/
#

ENV RUBY_MAJOR 2.2
ENV RUBY_VERSION 2.2.3
ENV RUBY_DOWNLOAD_SHA256 df795f2f99860745a416092a4004b016ccf77e8b82dec956b120f18bdc71edce
ENV RUBYGEMS_VERSION 2.6.6
ENV BUNDLER_VERSION 1.10.6

# Skip installing gem documentation
RUN mkdir -p /usr/local/etc \
	&& { \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /usr/local/etc/gemrc

# Some of ruby's build scripts are written in ruby
# Purge this later to make sure our final image uses what we just built
RUN set -ex \
	&& buildDeps=' \
		bison \
		libgdbm-dev \
		ruby \
	' \
	&& apt-get -qq clean \
	&& apt-get -qq update \
	&& apt-get -qq install -y --no-install-recommends $buildDeps \
	&& rm -rf /var/lib/apt/lists/* \
	&& curl -fSL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
	&& echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/src/ruby \
	&& tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 \
	&& rm ruby.tar.gz \
	&& cd /usr/src/ruby \
	&& { echo '#define ENABLE_PATH_CHECK 0'; echo; cat file.c; } > file.c.new && mv file.c.new file.c \
	&& autoconf \
	&& ./configure \
	    --disable-install-doc \
		> ruby.make.configure.log \
	&& make -j"$(nproc)" > ruby.make.log \
	&& make install > ruby.make.install.log \
	&& apt-get -qq purge -y --auto-remove $buildDeps \
	&& apt-get -qq clean \
	&& gem update --system $RUBYGEMS_VERSION > ruby.rubygems.install.log \
	&& rm -r /usr/src/ruby

RUN gem install bundler --version "$BUNDLER_VERSION"

# Install things globally
# Don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
	BUNDLE_BIN="$GEM_HOME/bin" \
	BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
	&& chmod 777 "$GEM_HOME" "$BUNDLE_BIN"
#
# Install Node.js
#
# Based on:  https://hub.docker.com/_/node/
#

ENV NODE_VERSION 5.1.0

# GPG keys listed at https://github.com/nodejs/node
RUN set -ex \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "9554F04D7259F04124DE6B476D5A82AC7E37093B" >> node.keys.log 2>&1 \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "94AE36675C464D64BAFA68DD7434390BDBE9B9C5" >> node.keys.log 2>&1 \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93" >> node.keys.log 2>&1 \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "FD3A5288F042B6850C66B31F09FE44734EB7990E" >> node.keys.log 2>&1 \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "71DCFD284A79C3B38668286BC97EC7A07EDE3FC1" >> node.keys.log 2>&1 \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "DD8F2338BAE7501E3DD5AC78C273792F7D83545D" >> node.keys.log 2>&1 \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "B9AE9905FFD7803F25714661B63B535A4C206CA9" >> node.keys.log 2>&1 \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8" >> node.keys.log 2>&1

ENV NPM_CONFIG_LOGLEVEL info

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

################################################################################
# Additional packages we need.
################################################################################
RUN apt-get -qq clean && \
    apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends \
        gawk \
        sshpass \
    && \
    apt-get -qq clean

################################################################################
# Install Python packages.
################################################################################
COPY docker-jekyll-site/requirements3.txt /docker-jekyll-site-temp/requirements3.txt
RUN dos2unix /docker-jekyll-site-temp/requirements3.txt && \
    pip install -r /docker-jekyll-site-temp/requirements3.txt

################################################################################
# Install Ruby gems.
################################################################################
COPY docker-jekyll-site/Gemfile /docker-jekyll-site-temp/Gemfile
COPY docker-jekyll-site/Gemfile.lock /docker-jekyll-site-temp/Gemfile.lock
RUN dos2unix /docker-jekyll-site-temp/Gemfile && \
    dos2unix /docker-jekyll-site-temp/Gemfile.lock && \
    cd /docker-jekyll-site-temp && bundle install

################################################################################
# Install Node modules. We will need to link to these at runtime.
################################################################################
COPY docker-jekyll-site/npm-shrinkwrap.json /docker-jekyll-site-temp/npm-shrinkwrap.json
COPY docker-jekyll-site/package.json /docker-jekyll-site-temp/package.json
RUN dos2unix /docker-jekyll-site-temp/npm-shrinkwrap.json && \
    dos2unix /docker-jekyll-site-temp/package.json && \
    cd /docker-jekyll-site-temp && npm install

################################################################################
# From before-base.
################################################################################

# Port where we serve the files
EXPOSE 4000

# Volume where the site will persist
VOLUME ["/docker-jekyll-site/site"]

################################################################################
# Set up our entrypoint script.
################################################################################
COPY docker-jekyll-site/docker-jekyll-site-entrypoint.sh /docker-jekyll-site-entrypoint.sh
RUN dos2unix /docker-jekyll-site-entrypoint.sh && \
    chmod +x /docker-jekyll-site-entrypoint.sh

# Run the wrapper script
CMD ["/docker-jekyll-site-entrypoint.sh"]
