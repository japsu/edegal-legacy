FROM ubuntu:latest
MAINTAINER Santtu Pajukanta <santtu@pajukanta.fi>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list
RUN apt-get update
RUN apt-get install -y git imagemagick mongodb-10gen curl build-essential
RUN groupadd edegal
RUN useradd -m -c 'Edegal Image Gallery' -d /srv/edegal -g edegal edegal

USER edegal
ENV HOME /srv/edegal

RUN git clone https://github.com/creationix/nvm /srv/edegal/nvm
RUN /bin/bash -c "source /srv/edegal/nvm/nvm.sh && nvm install v0.10.21 && nvm alias default v0.10.21"

ADD . /srv/edegal/app
RUN /bin/bash -c "source /srv/edegal/nvm/nvm.sh && nvm use default && cd /srv/edegal/app && npm install"
