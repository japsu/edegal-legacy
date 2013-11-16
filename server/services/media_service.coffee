_ = require 'underscore'

{setThumbnail} = require '../../shared/helpers/media_helper.coffee'
{walkAncestors} = require '../helpers/tree_helper.coffee'

{updateAlbum} = require './album_service.coffee'

addMediaToPicture = (picturePath, media) ->
  query =
    'pictures.path': picturePath

  update =
    '$push':
      'pictures.$.media': media

  Album.findAndModify query, update, {'new': true}
