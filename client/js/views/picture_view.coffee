{View} = require './helpers/view_helper.coffee'

class PictureView extends View
  el: '#picture'

  getBreadcrumb: ->
    # XXX fugly
    album = @model.get('album')

    album.get('breadcrumb').concat [
      {
        title: album.get('title')
        path: album.get('path')
      }
      {
        title: @model.get('title')
        path: @model.get('path')
      }
    ]

  renderContent: ->
    # XXX better media selection algorithm
    @$el.render @model.toJSON(),
      picture:
        src: -> _.first(@media)?.src ? ''
        alt: -> @title

module.exports = {PictureView}