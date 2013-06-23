Backbone = require 'backbone'
require 'backbone-relational'

{Pictures} = require './picture.coffee'

class Album extends Backbone.RelationalModel
  initialize: ->
    @on 'reset, change:pictures', ->
      previous = null

      @get('pictures').forEach (picture) ->
        if previous
          previous.set 'next', picture.get('path')
          picture.set 'previous', previous.get('path')

        previous = picture

  relations: [
    {
      type: Backbone.HasMany,
      key: 'pictures',
      relatedModel: 'Picture',
      collectionType: 'Pictures',
      reverseRelation:
        key: 'album'
        includeInJSON: false
    }
  ]
  url: -> '/v2' + @get('path')
  idAttribute: 'path'

class Albums extends Backbone.Collection
  model: Album

albums = new Albums

module.exports = {Album, Albums, albums} 
window.edegalModelsAlbum = module.exports if window?
Backbone.Relational.store.addModelScope module.exports