

if require.main is module
  argv = require('optimist')
    .usage('Usage: $0 -s 800x240 [-s 1200x700@85] [-p /foo]')
    .options('size', alias: 's', demand: true, describe: 'Size (WIDTHxHEIGHT[@QUALITY])')
    .options('path', alias: 'p', describe: 'Process only single album (default: all)')
    .options('output', alias: 'o', default: 'previews', 'Output folder for previews, relative to --root')
    .options('root', alias: 'r', default: 'public', 'Document root')
    .options('concurrency', alias: 'j', default: 4, 'Maximum parallel processes')
    .options('quiet', alias: 'q', boolean: true, "Don't print dots")
    .argv

  argv.size = [argv.size] unless _.isArray argv.size
  sizes = argv.size.map parseSize
  {concurrency, root, output, quiet} = argv

  Q.when null, ->
    if argv.path
      Q.ninvoke albums.find($or: [
        { path: argv.path},
        { 'breadcrumb.path': argv.path }
      ]), 'toArray'
    else
      Q.ninvoke albums.find(), 'toArray'
  .then (albums) ->
    createPreviews {albums, sizes, concurrency, root, output, quiet}
  .then ->
    process.stdout.write '\n'
    process.exit()
  .done()
