# Edegal - A web picture gallery

[![Build Status](https://travis-ci.org/japsu/edegal-express.png)](https://travis-ci.org/japsu/edegal-express)

Edegal is a web picture gallery written in Node.js and designed with performance and scalability in mind.

High performance is achieved through the usage of a dead simple REST JSON API in which most cache misses only result in a single database query that returns a single document.

Edegal is a work in progress.

## Goals

* Successfully replace Coppermine Image Gallery at http://kuvat.aniki.fi
  * 49,860 files in 619 albums and 110 categories viewed 6,118,935 times over the course of 9 years (as of 22nd June 2013)
* Drop some jaws with stunning visuals and flawless usability
* Become the number one choice for a self-hosted image gallery for serious hobbyist photographers

## Getting started

Assuming you have MongoDB installed. If you need to authenticate to MongoDB, edit `server/db.coffee` (look for `new Mongolian`, change url to `mongo://user:password@localhost/edegal`).

    # install node.js (may skip if node -v returns something >= 0.8 already)
    git clone https://github.com/creationix/nvm ~/.nvm
    source ~/.nvm/nvm.sh
    nvm install v0.10.12

    # install build tools
    npm -g install bower james coffee-script

    # install dependencies
    npm install
    bower install

    # build (plain "james" for a debug build)
    james build

    # run tests
    npm test

    # import some dummy data
    coffee example/load_seed.coffee

    # run server
    npm start

    # enjoy
    iexplore http://localhost:9001

## Technology choices

* Development tools
  * [Node.js](https://github.com/joyent/node)
  * [James](https://github.com/leonidas/james.js)
  * [Browserify](https://github.com/substack/node-browserify)
  * [CoffeeScript](https://github.com/jashkenas/coffee-script)
  * [Jade](https://github.com/visionmedia/jade) templates for static HTML
  * [Stylus](https://github.com/learnboost/stylus)
  * [UglifyJS](https://github.com/mishoo/UglifyJS2)
  * [Mocha](https://github.com/visionmedia/mocha)
  * [Sinon](https://github.com/cjohansen/Sinon.JS)
* Backend
  * [Node.js](https://github.com/joyent/node)
  * [Express](https://github.com/visionmedia/express)
  * [MongoDB](https://github.com/mongodb/mongo)
  * [nginx](https://github.com/nginx/nginx)
* Frontend
  * [Backbone](https://github.com/documentcloud/backbone)
  * [Backbone.Relational](https://github.com/PaulUithol/Backbone-relational)
  * [Transparency](https://github.com/leonidas/transparency)
  * [Hammer.js](https://github.com/EightMedia/hammer.js)

## Layout

* server: all server-side code
* client: all client-side code
  * coffee
  * jade
  * stylus
  * images

## Testimonials

* "That's mighty fast!"
* "I don't remember having ever run into another web gallery as nifty as this!"