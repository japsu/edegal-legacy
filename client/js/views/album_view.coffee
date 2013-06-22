{View} = require './helpers/view_helper.coffee'

class AlbumView extends View
  el: '#album'
  renderContent: ->
    @$el.render @model.toJSON(),
      subalbums:
        path:
          href: -> @path
      pictures:
        path:
          href: -> @path

module.exports = {AlbumView}