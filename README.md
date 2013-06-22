# Edegal - A web picture gallery

Edegal is a web picture gallery written in Node.js and designed with performance and scalability in mind.

High performance is achieved through the usage of a dead simple REST JSON API in which most cache misses only result in a single database query that returns a single document.

Edegal is a work in progress.

## Goals

* Successfully replace Coppermine Image Gallery at http://kuvat.aniki.fi
** 49,860 files in 619 albums and 110 categories viewed 6,118,935 times over the course of 9 years (as of 22nd June 2013)
** import script
* Drop some jaws with stunning visuals and flawless usability
* Become the number one choice for a self-hosted image gallery for serious hobbyist photographers
** Lightroom export

## Getting started

    npm install
    bower install
    james
    npm start
    iexplore http://localhost:9001

## Technology choices

* [James](https://github.com/leonidas/james.js)
* [Browserify](https://github.com/substack/node-browserify)
* [CoffeeScript](https://github.com/jashkenas/coffee-script)
* [Jade](https://github.com/visionmedia/jade) templates for static HTML
* [Stylus](https://github.com/learnboost/stylus)
* [UglifyJS](https://github.com/mishoo/UglifyJS2)
* [Express](https://github.com/visionmedia/express)
* [MongoDB](https://github.com/mongodb/mongo)
* [nginx](https://github.com/nginx/nginx)

## Layout

* server: all server-side code
* client: all client-side code
  * coffee
  * jade
  * stylus
  * images