{Schema} = require 'mongoose'

{mediaSchema, mediaSpec} = require './media.coffee'

exports.pictureSchema = pictureSchema = new Schema
  path:
    type: String
    required: true

  title:
    type: String
    required: true

  media: [mediaSchema]
  thumbnail: mediaSpec
