_          = require 'underscore'
Q          = require 'q'
path       = require 'path'
{newAlbum} = require '../server/services/album_service.coffee'
unused     = require '../server/db.coffee'

if require.main is module
  argv = require('optimist')
    .usage('Usage: $0 --title "Album title" --parent / [directory]')
    .options('title', alias: 't', demand: true, describe: 'Album title')
    .options('description', alias: 'd', default: '', describe: 'Album description')
    .options('parent', alias: 'p', describe: 'Path of the parent album')
    .argv

  attrs = _.pick argv, 'title', 'description'

  newAlbum(argv.parent, attrs).then ->
    process.exit()
  .done()
