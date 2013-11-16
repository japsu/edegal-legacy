_ = require 'underscore'
Q = require 'q'

{setThumbnail} = require '../../shared/helpers/media_helper'
{walkAncestors} = require '../helpers/tree_helper'

{updateAlbum} = require './album_service'
{Album} = require '../models/album'

exports.addMediaToPicture = (picturePath, media) ->
  media = [media] unless _.isArray media

  query =
    'pictures.path': picturePath

  update =
    $push:
      'pictures.$.media':
        '$each': media

  Q.ninvoke Album, 'findOneAndUpdate', query, update, {'new': true}
