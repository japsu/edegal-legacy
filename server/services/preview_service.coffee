path = require 'path' # XXX
fs = require 'fs'

_ = require 'underscore'
Q = require 'q'

# easyimg wrappers exported for stubbing
easyimg = require 'easyimage'
exports.resizeImage = Q.nbind easyimg.resize, easyimg
exports.getImageInfo = Q.nbind easyimg.info, easyimg

# mkdirp wrapper exported for stubbing
mkdirp = require 'mkdirp'
exports.makeDirectories = makeDirectories = Q.denodeify mkdirp

{addMediaToPicture} = require './media_service'
{getOriginal} = require '../../shared/helpers/media_helper'
{Semaphore} = require '../../shared/helpers/concurrency_helper'
config = require '../config'

DEFAULT_QUALITY = 60

fileExists = (filename) ->
  deferred = Q.defer()
  fs.exists filename, (exists) -> deferred.resolve exists
  deferred.promise

parseSize = (size) ->
  size = /(\d+)x(\d+)(?:@(\d+))?/.exec size
  return "Invalid size: #{size}" unless size

  width: parseInt size[1]
  height: parseInt size[2]
  quality: parseInt(size[3] ? DEFAULT_QUALITY)

mkPath = (first, theRest...) ->
  theRest = theRest.map (pathFrag) ->
    if pathFrag[0] == '/'
      pathFrag[1..]
    else
      pathFrag

  path.resolve first, theRest...

exports.createPreview = createPreview = (opts) ->
  {picture, size} = opts
  {width, height, quality} = size
  {root, previews} = config.paths

  albumPath = picture.albumPath()
  dstPathOnServer = path.join '/', previews, picture.path, "max#{width}x#{height}q#{quality}.jpg"

  if _.find(picture.media, (med) -> med.src == dstPathOnServer)
    return Q.when success: true, result: 'exists'

  resizeOpts = _.extend {}, size,
    src: mkPath root, getOriginal(picture).src
    dst: mkPath root, dstPathOnServer

  result = null
  fileExists(resizeOpts.dst).then (exists) ->
    if exists
      exports.getImageInfo(resizeOpts.dst).spread (existing) ->
        result = 'fileExists'
        existing
    else
      makeDirectories(path.dirname(resizeOpts.dst)).then ->
        exports.resizeImage(resizeOpts).spread (resized) ->
          result = 'created'
          resized
  .then (imageInfo) ->
    media =
      width: parseInt imageInfo.width
      height: parseInt imageInfo.height
      src: dstPathOnServer

    addMediaToPicture picture.path, media
  .then ->
    success: true
    result: result
  .fail (reason) ->
    console.warn reason.stack

    success: false
    result: 'failed'
    reason: reason

exports.createPreviews = createPreviews = (albums) ->
  {concurrency, sizes} = config

  albums = [albums] unless _.isArray albums

  magickSemaphore = new Semaphore concurrency

  albums.forEach (album) ->
    album.pictures.forEach (picture) ->
     sizes.forEach (size) ->
        do (album, picture, size) ->
          magickSemaphore.push ->
            createPreview
              picture: picture
              size: size

  magickSemaphore.finished()
