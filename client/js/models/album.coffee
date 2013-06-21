Backbone = require 'backbone'

{Pictures} = require './picture.coffee'
Model = require './helpers/model.coffee'

class Album extends Model
  defaults: ->
    pictures: []
    subalbums: []
  nestedCollections: ->
    pictures: Pictures
    subalbums: Albums
  url: -> '/v2' + @get('path')
  idAttribute: "path"

class Albums extends Backbone.Collection
  model: Album

albums = new Albums

window.edegalAlbumModels = module.exports = {Album, Albums, albums} 
