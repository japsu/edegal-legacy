Promise            = require 'bluebird'
_            = require 'lodash'

albumService = require '../services/album_service.coffee'

exports.walkAlbumsDepthFirst = (path, visitor, save=true) ->
  processSubalbums = (album) ->
    subalbumVisits = album.subalbums.map (subalbum) -> ->
      exports.walkAlbumsDepthFirst subalbum.path, visitor, save
    subalbumVisits.reduce(Promise.resolve, Promise()).then ->
      Promise.resolve visitor(album)

  if save
    albumService.updateAlbum path, processSubalbums
  else
    albumService.getAlbum(path).then processSubalbums

exports.walkAlbumsBreadthFirst = (path, visitor, save=true) ->
  processSubalbums = (album) ->
    subalbumVisits = album.subalbums.map (subalbum) -> ->
      exports.walkAlbumsBreadthFirst subalbum.path, visitor, save
    subalbumVisits.reduce(Promise.resolve, Promise())

  if save
    albumService.updateAlbum(path, visitor).then processSubalbums
  else
    albumService.getAlbum(path).then (album) ->
      Promise.resolve(visitor(album)).then -> processSubalbums album

exports.walkAncestors = (path, visitor, save=true) ->
  promise = if save
    albumService.updateAlbum(path, visitor)
  else
    albumService.getAlbum(path).then (album) ->
      Promise.resolve(visitor(album))

  promise.then (album) ->
    if _.isEmpty album.breadcrumb
      album
    else
      exports.walkAncestors _.last(album.breadcrumb).path, visitor, save
