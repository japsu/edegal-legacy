Promise  = require 'bluebird'
mongoose = require 'mongoose'
Promise.promisifyAll mongoose

{Album}  = require '../../server/models/album'
config   = require './test_config.json'


exports.connection = mongoose.connect config.database

emptyDatabase = (done) ->
  Promise.all([
    Album.removeAsync()
  ]).then ->
    done()

beforeEach emptyDatabase