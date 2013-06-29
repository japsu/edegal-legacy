_ = require 'underscore'

THUMBNAIL_HEIGHT = 240

exports.getOriginal = (picture) ->
  media = picture.media ? picture.get 'media'
  _.find media, (medium) -> medium.original
  
exports.getThumbnail = (picture) ->
  media = picture.media ? picture.get 'media'
  _.min media, (medium) -> Math.abs(medium.height - THUMBNAIL_HEIGHT)