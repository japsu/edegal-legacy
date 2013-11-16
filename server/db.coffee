mongoose = require 'mongoose'
config = require './config'
exports.connection = mongoose.connect config.database
