Backbone = require 'backbone'

class Picture extends Backbone.Model

class Pictures extends Backbone.Collection
  model: Picture

# Pictures only exist as subdocuments of ALbum.
# Therefore there is no global 'pictures' collection.

module.exports = {Picture, Pictures}