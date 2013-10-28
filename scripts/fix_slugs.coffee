path = require 'path'

_ = require 'underscore'
Q = require 'q'

{slugify, makeBreadcrumb, sanitizeFilename} = require '../shared/helpers/path_helper'
{getAlbum, saveAlbum} = require '../server/db'

recursivelyFixSlugs = (album, breadcrumb) ->
  album.path = path.join _.last(breadcrumb)?.path ? '/', slugify(album.title) unless album.path == '/'
  album.breadcrumb = breadcrumb

  newBreadcrumb = makeBreadcrumb album

  Q.all(album.subalbums.map (subalbum) -> getAlbum(subalbum.path)).then (subalbums) ->
    Q.all(subalbums.map (subalbum) -> recursivelyFixSlugs(subalbum, newBreadcrumb)).then ->
      album.subalbums = subalbums.map (subalbum) -> _.pick subalbum, 'path', 'title', 'thumbnail'
      album.pictures.forEach (picture) -> picture.path = path.join album.path, sanitizeFilename(picture.title)
      saveAlbum(album)

if require.main is module
  argv = require('optimist')
    .options('path', alias: 'p', default: '/')
    .argv

  getAlbum(argv.path).then (album) ->
    recursivelyFixSlugs album, album.breadcrumb
  .then ->
    process.exit()
  .done()