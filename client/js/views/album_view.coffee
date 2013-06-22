{View} = require './helpers/view_helper.coffee'

class AlbumView extends View
  el: '#album'
  renderContent: ->
    @$el.render @model.toJSON(),
      subalbums:
        link:
          href: -> @path
      pictures:
        link:
          href: -> @path

module.exports = {AlbumView}