{View} = require './helpers/view_helper.coffee'

class PictureView extends View
  el: '#picture'

  getBreadcrumb: ->
    # XXX fugly
    album = @model.get('album')

    breadcrumb = album.get('breadcrumb').concat [
      title: album.get('title')
      path: album.get('path')
    ]

    title: @model.get('title')
    breadcrumb: breadcrumb

module.exports = {PictureView}