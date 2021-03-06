path    = require 'path'

_       = require 'lodash'
Promise = require 'bluebird'
logger  = require 'winston'

{makeBreadcrumb, slugify} = require '../../shared/helpers/path_helper.coffee'
{Album} = require '../models/album.coffee'

PLACEHOLDER_IMAGE = '/images/example_content_360x240.jpg'

albumQuery = (path) ->
  $or: [
    { path },
    { 'pictures.path': path }
  ]

exports.getAlbum = getAlbum = (path) -> Album.findOneAsync albumQuery(path)

exports.getAlbumTree = getAlbumTree = (path) ->
  Album.find($or: [
    { path: path },
    { 'breadcrumb.path': path }
  ]).execAsync()

exports.updateAlbum = updateAlbum = (path, mutator) ->
  getAlbum(path).then (album) ->
    Promise.resolve(mutator(album)).then ->
      album.saveAsync()
    .then ->
      album

exports.newAlbum = newAlbum = (parentPath, attrs) ->
  {title} = attrs

  (if parentPath then getAlbum(parentPath) else Promise.resolve(null)).then (parentAlbum) ->
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

    album.saveAsync().then ->
      # Add album to parent's subalbums
      Album.updateAsync(
        { path: parentAlbum.path },
        {
          $push: { subalbums: _.pick(album, 'path', 'title', 'thumbnail')}
          $inc: { version: 1 }
        }
      ) if parentAlbum

      logger.info "Album created:", album.path

      album

exports.deleteAlbum = deleteAlbum = (path) ->
  Album.findOneAsync(path: path).then (album) ->
    throw new ReferenceError "No such album: #{path}" unless album

    Promise.all [
      Album.removeAsync(
        $or: [
          # Remove the album itself
          { path: path },

          # Remove all its descendants, too
          { 'breadcrumb.path': path }
        ]
      )

      # Remove the album from parents' subalbums
      Album.updateAsync(
        { 'subalbums.path': path },
        {
          $pull: { subalbums: { path: path }}
        }
      )
    ]
  .then ->
    logger.info 'Album removed:', path
