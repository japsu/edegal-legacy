$ = require 'jquery'
_ = require 'underscore'

{getContent} = require '../../models/helpers/content_helper.coffee'

WRAP_VERTICAL_UNUSABLE_PX = 50 # account for footer (45px) and add a small epsilon for borders etc.

exports.getPictureAreaDimensions = ->
  $wrap = $('#wrap')
  [$wrap.width, $wrap.height - WRAP_VERTICAL_UNUSABLE_PX]

exports.selectMedia = (picture) ->
  [maxWidth, maxHeight] = exports.getPictureAreaDimensions()

  media = picture.get('media')

  # find the largest that fits
  byWidth = (medium) -> medium.width
  mediaThatFit = _.filter media, (medium) -> medium.width <= maxWidth && medium.height <= maxHeight
  return _.max mediaThatFit, byWidth unless _.isEmpty mediaThatFit

  # fall back to the smallest
  _.min media, byWidth

exports.preloadMedia = (selector, path) ->
  getContent(path).then (content) ->
    {album, picture} = content
    selectedMedia = selectMedia picture
    return unless selectedMedia and selectedMedia.src
    $('<img/>').attr 'src', selectedMedia.src
  .done()

window.edegalViewHelperMedia = exports if window?