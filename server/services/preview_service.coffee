path = require 'path' # XXX
fs = require 'fs'

_ = require 'underscore'
Q = require 'q'

easyimg = require 'easyimage'
resizeImage = Q.nbind easyimg.resize, easyimg
getImageInfo = Q.nbind easyimg.info, easyimg

mkdirp = require 'mkdirp'
makeDirectories = Q.denodeify mkdirp

{updateAlbum} = require './album_service'
{getOriginal} = require '../../shared/helpers/media_helper'
{Semaphore} = require '../../shared/helpers/concurrency_helper'

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
  {albumPath, picture, size, root, output} = opts
  {width, height, quality} = size

  dstPathOnServer = path.join '/', output, picture.path, "max#{width}x#{height}q#{quality}.jpg"

  if _.find(picture.media, (med) -> med.src == dstPathOnServer)
    return Q.when success: true, result: 'exists'

  resizeOpts = _.extend {}, size,
    src: mkPath root, getOriginal(picture).src
    dst: mkPath root, dstPathOnServer

  result = null
  fileExists(resizeOpts.dst).then (exists) ->
    if exists
      getImageInfo(resizeOpts.dst).spread (existing) ->
        result = 'fileExists'
        existing
    else
      makeDirectories(path.dirname(resizeOpts.dst)).then ->
        resizeImage(resizeOpts).spread (resized) ->
          result = 'created'
          resized
  .then (imageInfo) ->
    medium =
      width: parseInt imageInfo.width
      height: parseInt imageInfo.height
      src: dstPathOnServer

    updateAlbum albumPath, (album) ->
      picture = _.find album.pictures, (pic) -> pic.path == picture.path
      picture.media.push medium
      picture.media = _.sortBy picture.media, (med) -> medium.width
  .then ->
    success: true
    result: result
  .fail (reason) ->
    success: false
    result: 'failed'

exports.createPreviews = createPreviews = (opts) ->
  {albums, sizes, root, output, concurrency} = opts

  magickSemaphore = new Semaphore concurrency

  albums.forEach (album) ->
    album.pictures.forEach (picture) ->
     sizes.forEach (size) ->
        do (album, picture, size) ->
          magickSemaphore.push ->
            createPreview
              albumPath: album.path
              picture: picture
              size: size
              root: root
              output: output

  magickSemaphore.finished()
