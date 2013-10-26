mongoose = require 'mongoose'
config = require '../server_config.json'
exports.connection = mongoose.connect config.database
