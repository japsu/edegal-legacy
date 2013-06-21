Backbone = require 'backbone'
require 'backbone-relational'

class Picture extends Backbone.RelationalModel

class Pictures extends Backbone.Collection
  model: Picture

# Pictures only exist as subdocuments of ALbum.
# Therefore there is no global 'pictures' collection.

module.exports = {Picture, Pictures}
Backbone.Relational.store.addModelScope module.exports