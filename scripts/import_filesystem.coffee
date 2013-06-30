path = require 'path'
fs = require 'fs'

_ = require 'underscore'
Q = require 'q'
Q.longStackSupport = true

easyimg = require 'easyimage'

{getAlbum, saveAlbum} = require '../server/db'
{makeBreadcrumb, slugify, sanitizeFilename} = require '../shared/helpers/path_helper'
{setThumbnail} = require '../shared/helpers/media_helper'

readDirectory = Q.nbind fs.readdir, fs
getImageInfo = Q.nbind easyimg.info, easyimg

# TODO get the real prefix somewhere
stripPrefix = (fullPath, prefix='/srv/work/edegal-express/public') ->
  throw 'Path is outside document root' if fullPath.indexOf(prefix) != 0
  fullPath[prefix.length..]

filesystemImport = (opts) ->
  {title, parent: parentPath, description, directory, root} = opts

  console?.dir directory

  Q.all([
    getAlbum(path: parentPath)
    readDirectory(path.resolve(root, directory))
  ]).spread (parent, files) ->
    Q.all(files.map((basename) ->
      fullPath = path.resolve root, directory, basename
      getImageInfo(fullPath)
    )).then (imageInfos) ->
      albumPath = path.join(parent.path, slugify(title))

      album =
        path: albumPath
        title: title
        description: description
        breadcrumb: makeBreadcrumb(parent)
        subalbums: []
        pictures: imageInfos.map (imageInfo) ->
          {name, width, height} = imageInfo[0]

          path: path.join(albumPath, sanitizeFilename(name))
          title: name
          media: [
            {
              src: stripPrefix path.resolve(directory, name)
              width: parseInt width
              height: parseInt height
              original: true
            }
          ]

      setThumbnail album
      parent.subalbums.push _.pick album, 'path', 'title', 'thumbnail'
      setThumbnail parent

      # not saved in parallel to prevent zombie album ending up in parent if saving album fails
      saveAlbum(album)
    .then ->
      saveAlbum(parent)

if require.main is module
  argv = require('optimist')
    .usage('Usage: $0 --title "Album title" --parent / [directory]')
    .options('title', alias: 't', demand: true, describe: 'Album title')
    .options('description', alias: 'd', default: '', describe: 'Album description')
    .options('parent', alias: 'p', demand: true, describe: 'Path of the parent album')
    .options('directory', alias: 'i', demand: true, describe: 'Directory to import (relative to --root)')
    .options('root', alias: 'r', default: 'public', describe: 'Document root')
    .argv

  filesystemImport(argv).then ->
    process.exit()
  .done()