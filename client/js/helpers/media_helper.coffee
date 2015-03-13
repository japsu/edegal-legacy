_ = require 'lodash'

{getContent} = require '../services/album_service.coffee'

WRAP_VERTICAL_UNUSABLE_PX = 50 # account for footer (45px) and add a small epsilon for borders etc.

exports.getPictureAreaDimensions = ->
  [window.innerWidth, window.innerHeight - WRAP_VERTICAL_UNUSABLE_PX]

exports.selectMedia = (picture) ->
  [maxWidth, maxHeight] = exports.getPictureAreaDimensions()

  # find the largest that fits
  byWidth = (medium) -> medium.width
  mediaThatFit = _.filter picture.media, (medium) ->
    medium.width <= maxWidth && medium.height <= maxHeight
  return _.max mediaThatFit, byWidth unless _.isEmpty mediaThatFit

  # fall back to the smallest
  _.min picture.media, byWidth

exports.preloadMedia = (path) ->
  getContent(path).then (content) ->
    {album, picture} = content
    selectedMedia = exports.selectMedia picture
    img = document.createElement 'img'
    img.src = selectedMedia.src

window.edegalViewHelperMedia = exports if window?
