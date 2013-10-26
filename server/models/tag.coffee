{Schema, model} = require 'mongoose'

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

Tag = model 'Tag', tag, 'tags'
