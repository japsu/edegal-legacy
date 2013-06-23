{View} = require './helpers/view_helper.coffee'
{selectMedia, preloadMedia} = require './helpers/media_helper.coffee'

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
    @$el.render @model.toJSON(),
      picture:
        src: => selectMedia(@model)?.src ? ''
        alt: -> @title
      'next-link':
        href: -> @next ? ''
        style: -> if @next then '' else 'display:none'
      'prev-link':
        href: -> @previous ? ''
        style: -> if @previous then '' else 'display:none'

    next = @model.get 'next'
    preloadMedia '#preload .next', next if next

    previous = @model.get 'previous'
    preloadMedia '#preload .previous', previous if previous

$ ->
  $(document).keydown (event) ->
    LEFT_ARROW = 37
    RIGHT_ARROW = 39

    $link = $()
    $link = $('#picture .next-link:visible') if event.keyCode == RIGHT_ARROW
    $link = $('#picture .prev-link:visible') if event.keyCode == LEFT_ARROW
    $link.click()

    return !$link.length

module.exports = {PictureView}