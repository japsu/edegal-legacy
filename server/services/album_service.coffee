{Album} = require '../models/album.coffee'
{consistentUpdate} = require '../helpers/version_helper.coffee'

exports.albumQuery = albumQuery = (path) ->
  $or: [
    { path },
    { 'pictures.path': path }
  ]

exports.getAlbum = getAlbum = (path) -> Q.ninvoke Album, 'findOne', albumQuery(path)

exports.updateAlbum = updateAlbum = (path, mutator) ->
  consistentUpdate Album, albumQuery(path), mutator
