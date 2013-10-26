Q            = require 'q'
_            = require 'underscore'

albumService = require '../services/album_service.coffee'

exports.walkAlbumsDepthFirst = (path, visitor, save=true) ->
  processSubalbums = (album) ->
    subalbumVisits = album.subalbums.map (subalbum) -> ->
      exports.walkAlbumsDepthFirst subalbum.path, visitor, save
    subalbumVisits.reduce(Q.when, Q()).then ->
      Q.when visitor(album)

  if save
    albumService.updateAlbum path, processSubalbums
  else
    albumService.getAlbum(path).then processSubalbums

exports.walkAlbumsBreadthFirst = (path, visitor, save=true) ->
  processSubalbums = (album) ->
    subalbumVisits = album.subalbums.map (subalbum) -> ->
      exports.walkAlbumsBreadthFirst subalbum.path, visitor, save
    subalbumVisits.reduce(Q.when, Q())

  if save
    albumService.updateAlbum(path, visitor).then processSubalbums
  else
    albumService.getAlbum(path).then (album) ->
      Q.when(visitor(album)).then processSubalbums

exports.walkAncestors = (path, visitor, save=true) ->
  promise = if save
    albumService.updateAlbum(path, visitor)
  else
    albumService.getAlbum(path).then (album) ->
      Q.when(visitor(album))

  promise.then (album) ->
    if _.isEmpty album.breadcrumb
      album
    else
      exports.walkAncestors _.last(album.breadcrumb).path, visitor, save
