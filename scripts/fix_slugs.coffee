path = require 'path'

_ = require 'underscore'
Q = require 'q'

{slugify, makeBreadcrumb} = require '../shared/helpers/path_helper'
{getAlbum, saveAlbum} = require '../server/db'

recursivelyFixSlugs = (album, breadcrumb) ->
  oldPath = album.path
  album.path = path.join _.last(breadcrumb)?.path ? '/', slugify(album.title) unless album.path == '/'
  album.breadcrumb = breadcrumb

  newBreadcrumb = makeBreadcrumb album

  Q.all(album.subalbums.map (subalbum) -> getAlbum(path: subalbum.path)).then (subalbums) ->
    Q.all(subalbums.map (subalbum) -> recursivelyFixSlugs(subalbum, newBreadcrumb)).then ->
      album.subalbums = subalbums.map (subalbum) -> _.pick subalbum, 'path', 'title', 'thumbnail'
      saveAlbum(album)

if require.main is module
  argv = require('optimist')
    .options('path', alias: 'p', default: '/')
    .argv

  getAlbum(path: argv.path).then (album) ->
    recursivelyFixSlugs album, album.breadcrumb
  .then ->
    process.exit()
  .done()