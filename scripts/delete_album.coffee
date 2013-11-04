Q = require 'q'

{deleteAlbum} = require '../server/services/album_service'

albumDeletor = (path) -> -> deleteAlbum path

if require.main is module
  argv = require('optimist')
    .usage('Usage: $0 /path')
    .argv

  argv._.map(albumDeletor).reduce(Q.when, Q()).then ->
    process.exit()
  .done()
