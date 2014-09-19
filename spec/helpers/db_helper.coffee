Promise        = require 'bluebird'
mongoose = require 'mongoose'
{Album}  = require '../../server/models/album'
config   = require './test_config.json'


exports.connection = mongoose.connect config.database

emptyDatabase = (done) ->
  Promise.all([
    Promise.ninvoke Album, 'remove', {}
  ]).then ->
    done()

beforeEach emptyDatabase