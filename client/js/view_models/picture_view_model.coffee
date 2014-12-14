$ = require 'jquery'
require 'jquery-hammerjs'
ko = require 'knockout'
require 'knockout-mapping'
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
    @picture = ko.mapping.fromJS {}
    @medium = ko.mapping.fromJS {}
    @original = ko.mapping.fromJS {}

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
    href = @picture[prevNext]()
    if href
      page href
      false

  setPicture: (picture) ->
    ko.mapping.fromJS picture, {}, @picture

    medium = mediaHelper.selectMedia picture
    ko.mapping.fromJS medium, {}, @medium

    original = theOtherMediaHelper.getOriginal picture
    ko.mapping.fromJS original, {}, @original
