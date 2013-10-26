{setThumbnail} = require '../../shared/helpers/media_helper.coffee'
{walkAncestors} = require '../helpers/tree_helper.coffee'

{updateAlbum} = require './album_service.coffee'

addMediaToPicture = (picturePath, media) ->
  updateAlbum picturePath, (album) ->
    picture = _.findWhere album.pictures, path: picturePath
    picture.media ?= []
    picture.media = _.union picture.media, [media]
    picture.media = _.sortBy picture.media, (medium) -> medium.width
  .then ->
    walkAncestors picturePath, setThumbnail
