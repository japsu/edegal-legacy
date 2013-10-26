_ = require 'underscore'

Backbone = require 'backbone'
require 'backbone-relational'

{getOriginal, getThumbnail} = require '../../../shared/helpers/media_helper.coffee'

class Picture extends Backbone.RelationalModel
  idAttribute: 'path'

  initialize: ->
    @on 'reset, change:media', ->
      @set 'original', getOriginal this
      @set 'thumbnail', getThumbnail this

  defaults: ->
    tags: []

class Pictures extends Backbone.Collection
  model: Picture

pictures = new Pictures

module.exports = {Picture, Pictures, pictures}
Backbone.Relational.store.addModelScope module.exports