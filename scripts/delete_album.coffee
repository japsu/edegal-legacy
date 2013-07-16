Q = require 'q'

{albums} = require '../server/db'

albumDeletor = (path) -> ->
  Q.ninvoke(albums, 'remove',
    $or: [
      # Remove the album itself
      { path: path },

      # Remove all its descendants, too
      { 'breadcrumb.path': path }
    ]
  ).then ->
    # Remove the album from parents' subalbums
    Q.ninvoke(albums, 'update',
      { 'subalbums.path': path },
      { $pull: { subalbums: { path: path }}}
    )

if require.main is module
  argv = require('optimist')
    .usage('Usage: $0 /path')
    .argv

  argv._.map(albumDeletor).reduce(Q.when, Q()).then ->
    process.exit()
  .done()