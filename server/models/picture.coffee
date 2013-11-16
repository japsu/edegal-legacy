{Schema} = require 'mongoose'

{mediaSchema, mediaSpec} = require './media.coffee'
{tagSpec} = require './tag.coffee'

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
