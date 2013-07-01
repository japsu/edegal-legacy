_ = require 'underscore'

path = require 'path'

{walkAlbumsDepthFirst} = require '../server/helpers/tree_helper'

fixAlbum = (album) ->
  album.pictures = _.sortBy album.pictures, (picture) -> path.basename picture.path
  album.title = album.title.replace ' - ', ' – '

if require.main is module
  walkAlbumsDepthFirst('/', fixAlbum).then ->
    process.exit()
  .done()