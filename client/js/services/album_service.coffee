Promise = require 'bluebird'
_ = require 'lodash'

mediaHelper = require '../../../shared/helpers/media_helper.coffee'


exports.getContent = (path) ->
  Promise.resolve($.getJSON('/v2' + path)).then (album) ->
    previous = null
    for picture in album.pictures
      mediaHelper.setPictureThumbnail picture

      if previous
        previous.next = picture.path
        picture.previous = previous.path

      previous = picture

    picture = _.find album.pictures, path: path
    {album, picture}
