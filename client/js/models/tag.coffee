Backbone = require 'backbone'
require 'backbone-relational'

{Picture, Pictures} = require './picture.coffee'

class Tag extends Backbone.RelationalModel
  initialize: ->

  relations: [
    {
      type: Backbone.HasMany,
      key: 'pictures',
      relatedModel: 'TagPicture',
      collectionType: 'TagPictures',
      reverseRelation:
        key: 'tag'
        includeInJSON: false
    }
  ]
  url: -> '/v2' + @get('path')
  idAttribute: 'path'

class Tags extends Backbone.Collection
  model: Tag

class TagPicture extends Picture

class TagPictures extends Backbone.Collection
  model: TagPicture

tags = new Tags
tagPictures = new TagPictures

module.exports = {Tag, Tags, tags, TagPicture, TagPictures, tagPictures} 
window.edegalModelsTag = module.exports if window?
Backbone.Relational.store.addModelScope module.exports