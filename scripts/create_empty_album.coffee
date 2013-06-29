_ = require 'underscore'
Q = require 'q'

{getAlbum, saveAlbum} = require '../server/db'
{makeBreadcrumb, slugify} = require '../shared/helpers/path_helper'

PLACEHOLDER_IMAGE = '/images/example_content_360x240.jpg'

createEmptyAlbum = (opts) ->
  {title, parent: parentPath, description} = opts

  (if parentPath then getAlbum(path: parentPath) else Q.when(null)).then (parentAlbum) ->
    if parentPath and not parentAlbum
      throw 'Parent album not found'

    if parentAlbum
      albumPath = path.join parentAlbum.path, slugify(title)
      breadcrumb = makeBreadcrumb parentAlbum
    else
      # creating the root album
      albumPath = '/'
      breadcrumb = []

    album =
      path: albumPath
      title: title
      description: description
      breadcrumb: breadcrumb
      subalbums: []
      pictures: []
      thumbnail:
        src: PLACEHOLDER_IMAGE
        width: 360
        height: 240

    saveAlbum(album).then ->
      if parentAlbum
        parentAlbum.subalbums.push _.pick album, 'path', 'title', 'thumbnail'
        saveAlbum parentAlbum

if require.main is module
  argv = require('optimist')
    .usage('Usage: $0 --title "Album title" --parent / [directory]')
    .options('title', alias: 't', demand: true, describe: 'Album title')
    .options('description', alias: 'd', default: '', describe: 'Album description')
    .options('parent', alias: 'p', describe: 'Path of the parent album')
    .argv

  createEmptyAlbum(argv).then ->
    process.exit()
  .done()