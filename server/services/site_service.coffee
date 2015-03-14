Promise = require 'bluebird'
{Album} = require '../models/album'

exports.setup = -> Album.ensureIndexesAsync()
