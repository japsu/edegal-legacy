_       = require 'underscore'
Q       = require 'q'
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

exports.getAlbum = getAlbum = (path) -> Q.ninvoke Album, 'findOne', albumQuery(path)

# TODO path/title changes should be reflected in parent subalbums
# TODO path/title changes should be reflected in subalbum paths/breadcrumbs
exports.updateAlbum = updateAlbum = (path, mutator) ->
  consistentUpdate Album, albumQuery(path), mutator

exports.newAlbum = newAlbum = (parentPath, attrs) ->
  {title} = attrs

  (if parentPath then getAlbum(parentPath) else Q.when(null)).then (parentAlbum) ->
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
      subalbums: []
      pictures: []
      thumbnail:
        src: PLACEHOLDER_IMAGE
        width: 360
        height: 240

    console?.log JSON.stringify attrs

    album = new Album attrs

    save(album).then ->
      # Add album to parent's subalbums
      Q.ninvoke(Album, 'update',
        { path: parentAlbum.path },
        {
          $push: { subalbums: _.pick(album, 'path', 'title', 'thumbnail')}
          $inc: { version: 1 }
        }
      ) if parentAlbum

exports.deleteAlbum = deleteAlbum = (path) ->
  Q.all [
    Q.ninvoke(Album, 'remove',
      $or: [
        # Remove the album itself
        { path: path },

        # Remove all its descendants, too
        { 'breadcrumb.path': path }
      ]
    )

    # Remove the album from parents' subalbums
    Q.ninvoke(Album, 'update',
      { 'subalbums.path': path },
      {
        $pull: { subalbums: { path: path }}
        $inc: { version: 1 }
      }
    )
  ]
