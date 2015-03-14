Promise = require 'bluebird'
_ = require 'lodash'

mediaHelper = require '../../../shared/helpers/media_helper.coffee'


cache = {}

exports.getAsync = (path) ->
  new Promise (resolve, reject) ->
    xhr = new XMLHttpRequest
    xhr.addEventListener "error", reject
    xhr.addEventListener "load", resolve
    xhr.open "GET", path
    xhr.send null

exports.getJSON = (path) ->
  exports.getAsync(path).then (event) ->
    JSON.parse event.target.responseText

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
