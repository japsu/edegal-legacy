Q        = require 'q'
mongoose = require 'mongoose'
{Album}  = require '../../server/models/album'
config   = require './test_config.json'


exports.connection = mongoose.connect config.database

emptyDatabase = (done) ->
  Q.all([
    Q.ninvoke Album, 'remove', {}
  ]).then ->
    done()
  .done()
