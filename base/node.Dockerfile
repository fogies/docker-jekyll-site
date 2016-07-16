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
