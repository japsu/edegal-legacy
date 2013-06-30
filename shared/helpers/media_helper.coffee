_ = require 'underscore'

THUMBNAIL_HEIGHT = 240

exports.getOriginal = (picture) ->
  media = picture.media ? picture.get 'media'
  _.find media, (medium) -> medium.original
  
exports.getThumbnail = (picture) ->
  media = picture.media ? picture.get 'media'
  _.min media, (medium) -> Math.abs(medium.height - THUMBNAIL_HEIGHT)


exports.getFirstLandscapePicture = (pictures) ->
  _.find pictures, (picture) ->
    anyMedia = _.first picture.media
    anyMedia.width >= anyMedia.height

exports.selectThumbnail = (album) ->
  return pictureThumbnail if (picture = exports.getFirstLandscapePicture album.pictures) and (pictureThumbnail = exports.getThumbnail picture)
  return pictureThumbnail if (picture = _.first album.pictures) and (pictureThumbnail = exports.getThumbnail picture)
  return subalbum.thumbnail if (subalbum = _.first album.subalbums) and subalbum.thumbnail
  { src: PLACEHOLDER_IMAGE, width: 360, height: 240 }

exports.setThumbnail = (album) -> album.thumbnail = exports.selectThumbnail album