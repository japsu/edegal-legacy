_       = require 'lodash'
Promise       = require 'bluebird'
path    = require 'path'
{makeBreadcrumb, slugify} = require '../../shared/helpers/path_helper.coffee'
{Album} = require '../models/album.coffee'
{consistentUpdate, save} = require '../helpers/model_helper.coffee'

PLACEHOLDER_IMAGE = '/images/example_content_360x240.jpg'

albumQuery = (path) ->
  $or: [
    { path },
    { 'pictures.path': path }
  ]

exports.getAlbum = getAlbum = (path) -> Promise.ninvoke Album, 'findOne', albumQuery(path)

exports.getAlbumTree = getAlbumTree = (path) ->
  Promise.ninvoke Album.find($or: [
    { path: path },
    { 'breadcrumb.path': path }
  ]), 'exec'

exports.updateAlbum = updateAlbum = (path, mutator) ->
  getAlbum(path).then (album) ->
    Promise.when(mutator(album)).then ->
      save album
    .then ->
      album

exports.newAlbum = newAlbum = (parentPath, attrs) ->
  {title} = attrs

  (if parentPath then getAlbum(parentPath) else Promise.when(null)).then (parentAlbum) ->
    if parentPath and not parentAlbum
      # TODO exception type
      throw 'Parent album not found'

    if parentAlbum
      albumPath = path.join parentAlbum.path, slugify(title)
      breadcrumb = makeBreadcrumb parentAlbum
    else
      # creating the root album
      albumPath = '/'
      breadcrumb = []

    attrs = _.defaults {}, attrs,
      path: albumPath
      breadcrumb: breadcrumb

    album = new Album attrs

    save(album).then ->
      # Add album to parent's subalbums
      Promise.ninvoke(Album, 'update',
        { path: parentAlbum.path },
        {
          $push: { subalbums: _.pick(album, 'path', 'title', 'thumbnail')}
          $inc: { version: 1 }
        }
      ) if parentAlbum

      album

exports.deleteAlbum = deleteAlbum = (path) ->
  Promise.all [
    Promise.ninvoke(Album, 'remove',
      $or: [
        # Remove the album itself
        { path: path },

        # Remove all its descendants, too
        { 'breadcrumb.path': path }
      ]
    )

    # Remove the album from parents' subalbums
    Promise.ninvoke(Album, 'update',
      { 'subalbums.path': path },
      {
        $pull: { subalbums: { path: path }}
      }
    )
  ]
