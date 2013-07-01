{View} = require './helpers/view_helper.coffee'
{preloadMedia} = require './helpers/media_helper.coffee'

class AlbumView extends View
  el: '#album'
  renderContent: ->
    @$el.render @model.toJSON(),
      subalbums:
        thumb:
          src: -> @thumbnail.src
          alt: -> @title
        link:
          href: -> @path
      pictures:
        thumb:
          src: -> @thumbnail.src
          width: -> @thumbnail.width
          alt: -> @title
        link:
          href: -> @path

    first = @model.get('pictures').first()
    preloadMedia first if first

module.exports = {AlbumView}