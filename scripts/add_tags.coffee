_ = require 'underscore'

{getAlbum, saveAlbum} = require '../server/db'

applyTags = (args) ->
  {tag: newTags, path} = args

  getAlbum(path).then (album) ->
    picture = _.findWhere album.pictures, path: path
    existingTags = picture.tags ? []
    picture.tags = _.union existingTags, newTags
    saveAlbum album

if require.main is module
  argv = require('optimist')
    .usage('Usage: $0 --path /path/to/picture --tag foo --tag bar')
    .options('tag', alias: 't', demand: true, describe: 'The tag to apply')
    .options('path', alias: 'p', describe: 'Path to picture')
    .argv

  argv.tag = [argv.tag] unless _.isArray argv.tag

  applyTags(argv).then ->
    process.exit()
  .done()