Backbone = require 'backbone'

class AlbumView extends Backbone.View
  el: '#album'
  render: ->
    $('.view').hide()
    @$('.content').text(JSON.stringify(@model.toJSON()))
    @$el.show()

module.exports = {AlbumView}