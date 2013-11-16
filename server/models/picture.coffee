{Schema} = require 'mongoose'

{stripLastComponent} = require '../../shared/helpers/path_helper'
{mediaSchema, mediaSpec} = require './media'
{tagSpec} = require './tag'

exports.pictureSchema = pictureSchema = new Schema {
  path:
    type: String
    required: true

  title:
    type: String
    required: true

  media: [mediaSchema]

  tags:
    type: [tagSpec]
    'default': -> []
}, {_id: false}

pictureSchema.methods.albumPath = () ->
  stripLastComponent @path
