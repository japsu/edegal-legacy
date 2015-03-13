$ = require 'jquery'
require 'jquery-hammerjs'
ko = require 'knockout'
page = require 'page'

mediaHelper = require '../helpers/media_helper.coffee'
theOtherMediaHelper = require '../../../shared/helpers/media_helper.coffee'


PREV_PICTURE_KEYCODES = [
  37 # left arrow
  33 # page up
]
NEXT_PICTURE_KEYCODES = [
  39 # right arrow
  34 # page down
]


module.exports = class PictureViewModel
  constructor: ->
    @picture = ko.observable null
    @medium = ko.observable null
    @original = ko.observable null

    @setupKeyBindings()
    @setupGestures()

  setupKeyBindings: ->
    $(document).keydown @onKeyDown

  onKeyDown: (event) =>
    return true if event.altKey or event.ctrlKey or event.metaKey

    if event.keyCode in NEXT_PICTURE_KEYCODES
      @goTo 'next'
    else if event.keyCode in PREV_PICTURE_KEYCODES
      @goTo 'previous'

  setupGestures: ->
    hammer = $('#picture').hammer()
    hammer.on 'swiperight', => @goTo 'next'
    hammer.on 'swipeleft', => @goTo 'previous'

  goTo: (prevNext) ->
    href = @picture()[prevNext]
    if href
      page href
      false

  setPicture: (picture) ->
    @picture picture

    medium = mediaHelper.selectMedia picture
    @medium medium

    original = theOtherMediaHelper.getOriginal picture
    @original original

    mediaHelper.preloadMedia picture.next if picture.next
    mediaHelper.preloadMedia picture.previous if picture.previous
