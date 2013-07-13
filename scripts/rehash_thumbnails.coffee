Q = require 'q'
_ = require 'underscore'

{getAlbum} = require '../server/db'
{setThumbnail} = require '../shared/helpers/media_helper'
{walkAlbumsDepthFirst} = require '../server/helpers/tree_helper'

rehashThumbnails = (path='/') ->
  walkAlbumsDepthFirst path, (album) ->
    Q.all(album.subalbums.map((subalbum) -> getAlbum( subalbum.path))).then (subalbums) ->
      album.subalbums = _.map subalbums, (subalbum) -> _.pick subalbum, 'path', 'title', 'thumbnail'
      setThumbnail album

if require.main is module
  argv = require('optimist')
    .usage('Usage: $0 [--path /foo]')
    .options('path', alias: 'p', default: '/', describe: 'The subtree under which to operate')
    .argv

  rehashThumbnails(argv.path).then ->
    process.exit()
  .done()