_ = require 'lodash'
Boom = require 'boom'
Joi = require 'joi'

albumService = require '../services/album_service'


exports.initialize = (server) ->
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
        albumService.getAlbum(path).then (album) ->
          if album?
            reply _.omit(album.toObject(), '_id')
          else
            reply Boom.notFound 'Album not found', path: path
        .catch (e) ->
          console?.error e
          reply Boom.badImplementation 'An error occurred while accessing the metadata database', e
