{walkAlbumsBreadthFirst} = require '../server/helpers/tree_helper'

printAlbum = (album) ->
  console.log "#{album.path} (#{album.pictures.length})"

printAlbums = (path) ->
  walkAlbumsBreadthFirst path, printAlbum, false

if require.main is module
  argv = require('optimist')
    .usage('Usage: $0 [--path /foo]')
    .options('path', alias: 'p', default: '/', describe: 'The subtree under which to operate')
    .argv

  printAlbums argv.path