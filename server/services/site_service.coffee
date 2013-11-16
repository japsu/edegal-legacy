Q = require 'q'
{Album} = require '../models/album'

exports.setup = -> Q.ninvoke Album, 'ensureIndexes'
