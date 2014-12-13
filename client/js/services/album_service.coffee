Promise = require 'bluebird'
_ = require 'lodash'

mediaHelper = require '../../../shared/helpers/media_helper.coffee'


exports.getContent = (path) ->
  Promise.resolve($.getJSON('/v2' + path)).then (album) ->
    console?.log 'gotContent', album
    mediaHelper.setPictureThumbnail picture for picture in album.pictures
    picture = _.find album.pictures, path: path
    {album, picture}
