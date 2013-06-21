Backbone = require 'backbone'

class PictureView extends Backbone.View
  el: '#picture'
  render: ->
    $('.view').hide()
    @$('.content').text(JSON.stringify(@model.toJSON()))
    @$el.show()

module.exports = {PictureView}