{Schema} = require 'mongoose'

exports.mediaSpec = mediaSpec =
  src:
    type: String
    required: true

  width:
    type: Number
    required: true

  height:
    type: Number
    required: true

  left:
    type: Number
    default: 0

  top:
    type: Number
    default: 0

  original:
    type: Boolean
    default: false
    
exports.mediaSchema = mediaSchema = new Schema mediaSpec
