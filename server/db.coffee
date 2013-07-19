Q = require 'q'
Mongolian = require 'mongolian'

{slugify} = require '../shared/helpers/path_helper'

config = require '../server_config.json'

db = new Mongolian config.database
albums = db.collection 'albums'
tags = db.collection 'tags'
picturesByTag = db.collection 'picturesByTag'

getAlbum = (path) -> Q.ninvoke albums, 'findOne', path: path
saveAlbum = Q.nbind albums.save, albums

tagPicture = (opts) ->
  {path, tag} = opts

  normalizeTag(tag).then (normalizedTag) ->
    findAndModifyAlbum
      query:
        'pictures.path': path
      update:
        $addToSet:
          'pictures.$.tags': normalizedTag

tagQuery = (tag) ->
  $or: [
    { tag: tag }
    { 'tag.synonyms': tag }
  ]

getTag = (tag) ->
  tagSlug = slugify(tag)
  Q.ninvoke db.tags, 'findOne', tagQuery tag

getPicturesByTag = (tag) ->
  getTag(tag).then (tagInfo) ->
    # basically http://cookbook.mongodb.org/patterns/pivot/
    mapFn = ->
      @pictures.forEach (picture) ->
        picture.tags?.forEach (tag) ->
          emit tag, pictures: [picture]

    reduceFn = (key, picturesies) ->
      result = pictures: []
      picturesies.forEach (picturezy) -> result.pictures = result.pictures.concat picturezy.pictures
      result

    Q.ninvoke(db.albums, 'mapReduce', mapFn, reduceFn,
      query:
        'pictures.tags': tagInfo.tag
      out:
        replace: 'picturesByTag'
    ).then ->
      Q.ninvoke picturesByTag, 'findOne', _id: tagInfo.tag


createIndexes = ->
  Q.all [
    Q.ninvoke(albums, 'ensureIndex', {path: 1}, {unique: true})
    Q.ninvoke(albums, 'ensureIndex', {'pictures.path': 1}, {unique: true, sparse: true})
    Q.ninvoke(albums, 'ensureIndex', {'pictures.tags': 1}, {sparse: true})
    Q.ninvoke(tags, 'ensureIndex', {tag: 1}, {unique: true})
    Q.ninvoke(tags, 'ensureIndex', {'tag.synonyms': 1}, {unique: true, sparse: true})
  ]

# Projections
albumsUserVisible =
  path: true
  title: true
  thumbnail: true
  subalbums: true
  pictures: true

module.exports = {albums, createIndexes, getAlbum, saveAlbum, albumsUserVisible}