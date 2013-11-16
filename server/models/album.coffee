{Schema} = mongoose = require 'mongoose'

{mediaSchema, mediaSpec} = require './media.coffee'
{pictureSchema} = require './picture.coffee'

exports.subalbumSchema = subalbumSchema = new Schema {
  path:
    type: String
    required: true

  title:
    type: String
    required: true

  thumbnail:
    type: mediaSpec
    required: false
}, {_id: false}

exports.breadcrumbSchema = breadcrumbSchema = new Schema {
  path:
    type: String
    required: true

  title:
    type: String
    required: true
}, {_id: false}

exports.albumSchema = albumSchema = new Schema
  path:
    type: String

  title:
    type: String
    required: true

  version:
    type: Number
    required: true
    'default': 0

  description: String

  breadcrumb: [breadcrumbSchema]

  subalbums: [subalbumSchema]

  pictures: [pictureSchema]

  thumbnail:
    type: mediaSpec
    required: false

albumSchema.index {path: 1}, {unique: true}
albumSchema.index {'pictures.path': 1}, {unique: true, sparse: true}
albumSchema.index {'breadcrumb.path': 1}

exports.Album = Album = mongoose.model 'Album', albumSchema, 'albums'
