Backbone = require 'backbone'
require 'backbone-relational'

class Picture extends Backbone.RelationalModel
  idAttribute: 'path'

class Pictures extends Backbone.Collection
  model: Picture

pictures = new Pictures

module.exports = {Picture, Pictures, pictures}
Backbone.Relational.store.addModelScope module.exports