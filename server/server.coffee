Hapi = require 'hapi'

require './db'
config = require './config'


module.exports = server = new Hapi.Server

server.connection
  host: config.host
  port: config.port


# Initialize controllers (order matters)
[
  './controllers/api_documentation_controller'
  './controllers/content_controller'
  './controllers/static_files_controller'
  './controllers/index_controller'
].forEach (controllerName) ->
  controller = require controllerName
  controller.initialize server


if require.main is module
  server.start -> console.log "Edegal running at #{config.host}:#{config.port}"
