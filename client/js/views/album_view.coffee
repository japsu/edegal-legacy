{View} = require './helpers/view_helper.coffee'

class AlbumView extends View
  el: '#album'
  renderContent: ->
    @$el.render @model.toJSON(),
      subalbums:
        thumb:
          src: -> @thumbnail
          alt: -> @title
        link:
          href: -> @path
      pictures:
        thumb:
          src: -> @thumbnail
          alt: -> @title
        link:
          href: -> @path

module.exports = {AlbumView}