{albums, createIndexes} = require '../server/db'

if require.main is module
  argv = require('optimist')
    .usage('Usage: $0 --really')
    .options('y', alias: 'really', demand: true)
    .argv

  Q.ninvoke(albums, 'drop').fail ->
    null
  .then ->
    createIndexes()
  .then ->
    process.exit()
  .done()