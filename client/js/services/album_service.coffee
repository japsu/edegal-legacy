Promise = require 'bluebird'
_ = require 'lodash'
$ = require 'jquery'

mediaHelper = require '../../../shared/helpers/media_helper.coffee'


cache = {}

# for testability
exports.getJSON = (path) -> Promise.resolve $.getJSON(path)

exports.getContent = (path) ->
  if cache[path]
    album = cache[path]
    picture = _.find album.pictures, path: path
    return Promise.resolve {album, picture}

  exports.getJSON('/v2' + path).then (album) ->
    cache[path] = album

    previous = null
    for picture in album.pictures
      cache[picture.path] = album

      mediaHelper.setPictureThumbnail picture

      if previous
        previous.next = picture.path
        picture.previous = previous.path

      previous = picture

    picture = _.find album.pictures, path: path
    {album, picture}
