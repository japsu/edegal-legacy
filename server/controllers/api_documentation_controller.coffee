config = require '../config'


exports.initialize = (server) ->
  server.register
    register: require('hapi-swagger')
    options:
      basePath: config.publicUrl
      apiVersion: require('../../package.json').version
    , ->
