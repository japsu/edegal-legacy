Promise = require 'bluebird'
{Album} = require '../models/album'

exports.setup = -> Promise.ninvoke Album, 'ensureIndexes'
