$ = require 'jquery'
require 'hammer-jquery'

{View} = require './helpers/view_helper.coffee'
{selectMedia, preloadMedia} = require './helpers/media_helper.coffee'
{getOriginal} = require '../../../shared/helpers/media_helper.coffee'
{makeBreadcrumb} = require '../../../shared/helpers/path_helper.coffee'

class PictureView extends View
  el: '#picture'

  getBreadcrumb: -> makeBreadcrumb @model.get('album'), @model

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
      'download-link':
        href: => getOriginal(@model)?.src ? ''
        style: => if getOriginal(@model) then '' else 'display:none'

    next = @model.get 'next'
    preloadMedia next if next

    previous = @model.get 'previous'
    preloadMedia previous if previous

$ ->
  # TODO encapsulate this $('#picture .prev-link:visible').click hackery!
  hammer = $('#picture').hammer()
  hammer.on 'swiperight', -> $('#picture .prev-link:visible').click()
  hammer.on 'swipeleft', -> $('#picture .next-link:visible').click()

  $(document).keydown (event) ->
    return true if event.altKey or event.ctrlKey or event.metaKey

    PREV_PICTURE_KEYCODES = [
      37 # left arrow
      33 # page up
    ]
    NEXT_PICTURE_KEYCODES = [
      39 # right arrow
      34  # page down
    ]

    $link = $()
    $link = $('#picture .next-link:visible') if event.keyCode in NEXT_PICTURE_KEYCODES
    $link = $('#picture .prev-link:visible') if event.keyCode in PREV_PICTURE_KEYCODES
    $link.click()

    return !$link.length

module.exports = {PictureView}