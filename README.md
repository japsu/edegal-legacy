# Edegal - A web picture gallery

[![Build Status](https://travis-ci.org/japsu/edegal.png)](https://travis-ci.org/japsu/edegal)

Edegal is a web picture gallery written in Node.js and designed with performance and scalability in mind.

High performance is achieved through the usage of a dead simple REST JSON API in which most cache misses only result in a single database query that returns a single document.

Edegal is a work in progress. See a demo at [uusi.kuvat.aniki.fi](http://uusi.kuvat.aniki.fi/) or [gallery.insomnia.fi](http://gallery.insomnia.fi).

## Goals

* Successfully replace Coppermine Image Gallery at [kuvat.aniki.fi](http://kuvat.aniki.fi)
  * 49,860 files in 619 albums and 110 categories viewed 6,118,935 times over the course of 9 years (as of 22nd June 2013)
* Provide picture galleries for the members of [Kapsi Internet-käyttäjät ry](http://www.kapsi.fi) requestable via a web self-service portal
* Drop some jaws with stunning visuals and flawless usability
* Become the number one choice for a self-hosted image gallery for serious hobbyist photographers

## Getting started

What is assumed:

* An UNIX-like operating system such as Ubuntu, CentOS or Mac OS X
* MongoDB installed and configured.
  * If you need to authenticate to MongoDB, edit `server_config.json`. The format is `mongo://user:password@localhost/edegal`).
  * By default, the database names used are `edegal` and `edegal_test` (for running tests).
* ImageMagick
* NodeJS (0.10.x) and NPM

Running a local server:

    # install dependencies and build
    npm install

    # run server
    npm start

    # enjoy
    open http://localhost:9001

Development:

    # install development tools into PATH
    npm -g install gulp

    # do an un-minified debug build, run a development server and watch for changes
    gulp

    # do a minified production build
    NODE_ENV=production gulp build

    # run tests
    npm test

## Getting pictures into the gallery

Sorry, this is a bit technical at the moment. There will be a browser-based uploader. Some day. I think.

At this moment you need to import album at a time.

    # (If you havent yet created the root album - do this only once)
    bin/edegal setup --title "My Photo Gallery"

    # Create an album
    bin/edegal album create --title "My New Album" --parent /

    # Import some photos
    bin/edegal import --move --path /my-new-album /path/to/files/*.jpg

You're all set!

## Configuration

There are configuration files for client and server, `client_config.json` and `server_config.json`.

### Client configuration (`client_config.json`)

Changing any values in `client_config.json` requires recompilation (`NODE_ENV=production gulp build`).

* `defaultLanguage`: `en` and `fi` supported.
* `analyticsAccount`: Put your Analytics token here to enable [Google Analytics](https://analytics.google.com) support.

### Server configuration (`server_config.json`)

* `database`: as accepted by `mongoose.connect`
* `port`: port number to listen on
* `hostname`: hostname or IP address to listen on
* `concurrency`: how many pictures to scale concurrently
* `sizes`: default preview sizes
  * `width`
  * `height`
  * `quality`

## Technology choices

* Development tools
  * [Node.js](https://github.com/joyent/node)
  * [Gulp](https://github.com/gulp/gulp)
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
  * [Mongoose](https://github.com/LearnBoost/mongoose)
  * [MongoDB](https://github.com/mongodb/mongo)
  * [nginx](https://github.com/nginx/nginx)
* Frontend
  * [Backbone](https://github.com/documentcloud/backbone)
  * [Backbone.Relational](https://github.com/PaulUithol/Backbone-relational)
  * [Transparency](https://github.com/leonidas/transparency)
  * [Hammer.js](https://github.com/EightMedia/hammer.js)

## Testimonials

* "That's mighty fast!"
* "I don't remember having ever run into another web gallery as nifty as this!"
* "I find the page load speed of Edegal incredible. But I think I've just grown accustomed to bad galleries."
* "Edegal seems exactly what I've been looking for!"
* "Edegal <3"
