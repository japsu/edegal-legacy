Q = require 'q'
_ = require 'underscore'

easyimg = require 'easyimage'
fs = require 'fs'
mkdirp = require 'mkdirp'
path = require 'path'

{Album} = require '../models/album'
{getOriginal} = require '../../shared/helpers/media_helper'
{Semaphore} = require '../../shared/helpers/concurrency_helper'
{setThumbnail} = require '../../shared/helpers/media_helper'
{updateAlbum} = require './album_service'
{walkAncestors} = require '../helpers/tree_helper'
config = require '../config'

exports.getImageInfo = Q.nbind easyimg.info, easyimg
exports.makeDirectories = makeDirectories = Q.denodeify mkdirp
exports.resizeImage = Q.nbind easyimg.resize, easyimg

DEFAULT_QUALITY = 60

exports.addMediaToPicture = addMediaToPicture = (picturePath, media) ->
  media = [media] unless _.isArray media

  query =
    'pictures.path': picturePath

  update =
    $push:
      'pictures.$.media':
        '$each': media

  Q.ninvoke Album, 'findOneAndUpdate', query, update, {'new': true}

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
