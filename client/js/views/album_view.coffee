Backbone = require 'backbone'
require 'transparency'

class AlbumView extends Backbone.View
  el: '#album'
  render: ->
    $('.view').hide()
    @$el.show().render @model.toJSON(),
      subalbums:
        path:
          href: -> @path
      pictures:
        path:
          href: -> @path

module.exports = {AlbumView}