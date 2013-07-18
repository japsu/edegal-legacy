path = require 'path'
fs = require 'fs'

_ = require 'underscore'
Q = require 'q'

easyimg = require 'easyimage'
resizeImage = Q.nbind easyimg.resize, easyimg
getImageInfo = Q.nbind easyimg.info, easyimg

mkdirp = require 'mkdirp'
makeDirectories = Q.denodeify mkdirp

{getAlbum, albums, saveAlbum} = require '../server/db'
{getOriginal} = require '../shared/helpers/media_helper'
{Semaphore} = require '../shared/helpers/concurrency_helper'

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

albumUpdateSemaphore = new Semaphore 1

createPreview = (opts) ->
  {albumPath, picture, size, root, output, quiet} = opts
  {width, height, quality} = size

  dstPathOnServer = path.join '/', output, picture.path, "max#{width}x#{height}q#{quality}.jpg"

  if _.find(picture.media, (med) -> med.src == dstPathOnServer)
    process.stdout.write '+'
    return Q.when {}

  resizeOpts = _.extend {}, size,
    src: mkPath root, getOriginal(picture).src
    dst: mkPath root, dstPathOnServer

  fileExists(resizeOpts.dst).then (exists) ->
    if exists
      getImageInfo(resizeOpts.dst).spread (existing) ->
        process.stdout.write '-' unless quiet
        existing
    else
      makeDirectories(path.dirname(resizeOpts.dst)).then ->
        resizeImage(resizeOpts).spread (resized) ->
          process.stdout.write '.' unless quiet
          resized
  .then (imageInfo) ->
    medium =
      width: parseInt imageInfo.width
      height: parseInt imageInfo.height
      src: dstPathOnServer

    albumUpdateSemaphore.push ->
      getAlbum(albumPath).then (album) ->
        picture = _.find album.pictures, (pic) -> pic.path == picture.path
        picture.media.push medium
        picture.media = _.sortBy picture.media, (med) -> medium.width
        saveAlbum album

  .fail ->
    console.warn '\nFailed to create thumbnail:', resizeOpts.src

createPreviews = (opts) ->
  {albums, sizes, root, output, quiet} = opts

  Q.all albums.map (album) ->
    Q.all album.pictures.map (picture) ->
      Q.all sizes.map (size) ->
        do (album, picture, size) ->
          magickSemaphore.push ->
            createPreview
              albumPath: album.path
              picture: picture
              size: size
              root: root
              output: output
              quiet: quiet

if require.main is module
  argv = require('optimist')
    .usage('Usage: $0 -s 800x240 [-s 1200x700@85] [-p /foo]')
    .options('size', alias: 's', demand: true, describe: 'Size (WIDTHxHEIGHT[@QUALITY])')
    .options('path', alias: 'p', describe: 'Process only single album (default: all)')
    .options('output', alias: 'o', default: 'previews', 'Output folder for previews, relative to --root')
    .options('root', alias: 'r', default: 'public', 'Document root')
    .options('concurrency', alias: 'j', default: 4, 'Maximum parallel processes')
    .options('quiet', alias: 'q', boolean: true, "Don't print dots")
    .argv

  argv.size = [argv.size] unless _.isArray argv.size
  sizes = argv.size.map parseSize
  {concurrency, root, output, quiet} = argv

  magickSemaphore = new Semaphore concurrency

  Q.when null, ->
    if argv.path
      Q.ninvoke albums.find($or: [
        { path: argv.path},
        { 'breadcrumb.path': argv.path }
      ]), 'toArray'
    else
      Q.ninvoke albums.find(), 'toArray'
  .then (albums) ->
    createPreviews {albums, sizes, concurrency, root, output, quiet}
  .then ->
    process.stdout.write '\n'
    process.exit()
  .done()