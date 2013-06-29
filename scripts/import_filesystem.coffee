path = require 'path'
fs = require 'fs'

Q = require 'q'
easyimg = reguire 'easyimage'

{findAlbum, saveAlbum} = require '../server/db'
{makeBreadcrumb, slugify} = require '../shared/helpers/path_helper'

readDirectory = Q.nfbind fs.readdir, fs
getImageInfo = Q.nfbind easyimg.info, easyimg

filesystemImport = (opts) ->
  {title, parent: parentPath, description} = opts

  Q.all([
    findAlbum(parentPath)
    readDirectory(directory)
  ]).spread (parent, files) ->
    album =
      path: path.join(parent.path, slugify(title))
      title: title
      description: description
      breadcrumb: makeBreadcrumb(parent)
      subalbums: []
      pictures: []

    Q.all files.map (file) ->
      getImageInfo(file).then (imageInfo) ->
        console?.log imageInfo
  .done()

if require.main is module
  argv = require(optimist)
    .usage('Usage: $0 --title "Album title" --parent / [directory]')
    .default('description', '')
    .demand(['title', 'parent'])
    .argv

  filesystemImport(argv)