Backbone = require 'backbone'
require 'backbone-relational'

{Pictures} = require './picture.coffee'

class Album extends Backbone.RelationalModel
  relations: [
    {
      type: Backbone.HasMany,
      key: 'subalbums',
      relatedModel: 'SubAlbum',
      collectionType: 'SubAlbums',
      reverseRelation:
        key: 'parentAlbum'
        includeInJSON: false
    },
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

class SubAlbum extends Backbone.RelationalModel
  idAttribute: 'path'

class SubAlbums extends Backbone.Collection
  model: SubAlbum

albums = new Albums

window.edegalAlbumModels = module.exports = {Album, Albums, SubAlbum, SubAlbums, albums} 
Backbone.Relational.store.addModelScope module.exports