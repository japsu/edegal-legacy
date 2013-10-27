{Schema} = mongoose = require 'mongoose'

exports.tagSpec = tagSpec =
  path:
    type: String
    required: true
    index: true

  title:
    type: String
    required: true

  tag:
    type: String
    required: true

exports.tagSchema = tagSchema = new Schema
  path:
    type: String
    required: true
    index: true

  title:
    type: String
    required: true

  tag:
    type: String
    required: true

  pictures: [] # TODO
  synonyms: [String]

Tag = mongoose.model 'Tag', tag, 'tags'
