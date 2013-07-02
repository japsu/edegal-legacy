Q = require 'q'

{getAlbum, saveAlbum} = require '../db'

exports.walkAlbumsDepthFirst = (path, visitor) ->
  getAlbum(path).then (album) ->
    subalbumVisits = album.subalbums.map (subalbum) -> -> exports.walkAlbumsDepthFirst subalbum.path, visitor
    subalbumVisits.reduce(Q.when, Q()).then ->
      Q.when visitor(album), ->
        saveAlbum album