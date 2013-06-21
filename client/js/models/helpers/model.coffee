Backbone = require 'backbone'

nestCollection = require './nesting.js'

class Model extends Backbone.Model
  initialize: ->
    console?.log "#{@constructor.name}.initialize"
    @nestedCollections ?= -> {}
    @_nestedCollections = @nestedCollections()
    for name, collectionClass of @_nestedCollections
      this[name] = nestCollection this, name, new collectionClass(@get(name))

  parse: (response, options) ->
    console?.log "#{@constructor.name}.parse"

    for name, unused of @_nestedCollections
      attributeHashes = response[name] ? []
      @get(name).reset attributeHashes
      delete response[name]

    response

module.exports = Model