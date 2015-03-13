_ = require 'lodash'
Hapi = require 'hapi'
Joi = require 'joi'
Boom = require 'boom'

require './db'
albumService = require './services/album_service'
config = require './config'

module.exports = server = new Hapi.Server

server.connection
  host: config.host
  port: config.port

server.register
  register: require('hapi-swagger')
  options:
    basePath: config.publicUrl
    apiVersion: require('../package.json').version
  , ->

server.route
  method: 'GET'
  path: '/v2/{path*}'
  config:
    tags: ['api']
    description: 'Get album or picture metadata'
    notes: 'This is the main endpoint of the metadata API. It will return you information about the album or picture at the given path.'
    validate:
      params:
        path: Joi.string().regex(/^[a-zA-Z0-9-\/]*$/).description('Path of an album or an image')
    handler: (request, reply) ->
      path = request.params.path ? ''
      path = "/#{path}"
      console?.log 'path', path
      albumService.getAlbum(path).then (album) ->
        if album?
          reply _.omit(album.toObject(), '_id')
        else
          reply Boom.notFound 'Album not found', path: path
      .catch (e) ->
        console?.error e
        reply Boom.badImplementation 'An error occurred while accessing the metadata database', e

[
  'assets'
  'pictures'
  'previews'
].forEach (staticDir) ->
  server.route
    method: 'GET'
    path: "/#{staticDir}/{param*}"
    handler:
      directory:
        path: "public/#{staticDir}"

server.route
  method: 'GET'
  path: '/{param*}',
  handler:
    file:
      path: 'public/index.html'

if require.main is module
  server.start -> console.log "Edegal running at #{config.host}:#{config.port}"
