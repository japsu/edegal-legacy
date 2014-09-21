path = require 'path'
fs = require 'fs'

Promise = require 'bluebird'
_ = require 'lodash'
easyimg = require 'easyimage'
mkdirp = require 'mkdirp'
logger = require 'winston'

{Album} = require '../models/album'
{getOriginal} = require '../../shared/helpers/media_helper'
{Semaphore} = require '../../shared/helpers/concurrency_helper'
{stripLastComponent} = require '../../shared/helpers/path_helper'
{setThumbnail} = require '../../shared/helpers/media_helper'
{updateAlbum} = require './album_service'
{walkAncestors, walkAlbumsDepthFirst} = require '../helpers/tree_helper'
config = require '../config'


exports.getImageInfo = (filename) -> Promise.resolve easyimg.info filename
exports.makeDirectories = makeDirectories = Promise.promisify mkdirp
exports.resizeImage = (opts) -> Promise.resolve easyimg.resize opts


docRoot = path.resolve config.paths.root
exports.stripDocRoot = stripDocRoot = (filePath) ->
  throw new Error "#{filePath} is outside document root" unless filePath.indexOf(docRoot) == 0
  filePath.replace docRoot, ''


DEFAULT_QUALITY = 60

exports.addMediaToPicture = addMediaToPicture = (picturePath, media) ->
  media = [media] unless _.isArray media

  query =
    'pictures.path': picturePath

  update =
    $push:
      'pictures.$.media':
        '$each': media

  Album.findOneAndUpdateAsync query, update, {'new': true}


fileExists = (filename) ->
  deferred = Promise.defer()
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

  albumPath = stripLastComponent picture.path
  dstPathOnServer = path.join '/', previews, picture.path, "#{width}x#{height}q#{quality}.jpg"

  if _.find(picture.media, (med) -> med.src == dstPathOnServer)
    return Promise.resolve success: true, result: 'exists'

  resizeOpts = _.extend {}, size,
    src: mkPath root, getOriginal(picture).src
    dst: dstPathOnServer

  result = null
  fileExists(resizeOpts.dst).then (exists) ->
    if exists
      exports.getImageInfo(resizeOpts.dst).then (existing) ->
        result = 'fileExists'
        existing
    else
      makeDirectories(path.dirname(resizeOpts.dst)).then ->
        exports.resizeImage(resizeOpts).then (resized) ->
          result = 'created'
          resized
  .then (imageInfo) ->
    media =
      width: imageInfo.width
      height: imageInfo.height
      src: stripDocRoot dstPathOnServer

    addMediaToPicture picture.path, media
  .then ->
    logger.info 'Preview created:', picture.path, "#{width}x#{height}" if result == 'created'

    success: true
    result: result
  .catch (reason) ->
    console.warn reason.stack

    success: false
    result: 'failed'
    reason: reason


exports.createPreviewsForAlbums = createPreviewsForAlbums = (albums) ->
  {concurrency, sizes} = config

  albums = [albums] unless _.isArray albums

  magickSemaphore = new Semaphore concurrency

  albums.forEach (album) ->
    album.pictures.forEach (picture) ->
     sizes.forEach (size) ->
        do (picture, size) ->
          magickSemaphore.push ->
            createPreview
              picture: picture
              size: size

  magickSemaphore.finished()


exports.createPreviewsForPictures = createPreviewsForPictures = (pictures) ->
  {concurrency, sizes} = config

  pictures = [pictures] unless _.isArray pictures

  magickSemaphore = new Semaphore concurrency

  pictures.forEach (picture) ->
   sizes.forEach (size) ->
      do (picture, size) ->
        magickSemaphore.push ->
          createPreview
            picture: picture
            size: size

  magickSemaphore.finished()


exports.rehashThumbnails = rehashThumbnails = (path='/') ->
  rehashAlbum = (album) ->
    logger.info 'Updating thumbnail and subalbums for album:', album.path 
    Promise.all(album.subalbums.map((subalbum) -> Album.findOneAsync(path: subalbum.path))).then (subalbums) ->
      album.subalbums = _.map subalbums, (subalbum) -> _.pick subalbum, 'path', 'title', 'thumbnail'
      setThumbnail album

  # TODO lazy: album is walked twice
  walkAlbumsDepthFirst path, rehashAlbum
  walkAncestors path, rehashAlbum
