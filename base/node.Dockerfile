#
# Install Node.js
#

RUN apt-get update && \
    apt-get install -y \
      curl \
    && \
    curl -sL https://deb.nodesource.com/setup | sudo bash - && \
    apt-get update && \
    apt-get install -y \
      nodejs \
    && \
    npm install npm -g && \
    apt-get clean
