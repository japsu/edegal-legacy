Promise = require 'bluebird'
mongoose = require 'mongoose'
Promise.promisifyAll mongoose

config = require './config'
exports.connection = mongoose.connect config.database
