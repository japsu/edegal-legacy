Q        = require 'q'
mongoose = require 'mongoose'
{Album}  = require '../../server/models/server'
config   = require '../test_config.json'


exports.connection = mongoose.connect config.database

emptyDatabase = (done) ->
  Q.all([
    Q.ninvoke Album, 'remove', {}
  ]).then ->
    done()
  .done()
