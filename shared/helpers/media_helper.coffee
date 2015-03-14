_ = require 'lodash'

THUMBNAIL_HEIGHT = 240

exports.getOriginal = (picture) ->
  _.find picture.media, (medium) -> medium.original

exports.selectPictureThumbnail = (picture) ->
  _.min picture.media, (medium) -> Math.abs(medium.height - THUMBNAIL_HEIGHT)

exports.setPictureThumbnail = (picture) ->
  picture.thumbnail = exports.selectPictureThumbnail picture

exports.getFirstLandscapePicture = (pictures) ->
  _.find pictures, (picture) ->
    anyMedia = _.first picture.media
    anyMedia.width >= anyMedia.height

exports.selectAlbumThumbnail = (album) ->
  return pictureThumbnail if (picture = exports.getFirstLandscapePicture album.pictures) and (pictureThumbnail = exports.selectPictureThumbnail picture)
  return pictureThumbnail if (picture = _.first album.pictures) and (pictureThumbnail = exports.selectPictureThumbnail picture)
  return subalbum.thumbnail if (subalbum = _.first album.subalbums) and subalbum.thumbnail
  null

exports.setAlbumThumbnail = (album) -> album.thumbnail = exports.selectAlbumThumbnail album
