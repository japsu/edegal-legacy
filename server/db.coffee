Q = require 'q'
Mongolian = require 'mongolian'
server = new Mongolian

db = server.db 'edegal'
albums = db.collection 'albums'

ensureIndexOnAlbums = Q.nbind albums.ensureIndex, albums
dropAlbums = Q.nbind albums.drop, albums
getAlbum = Q.nbind albums.findOne, albums
saveAlbum = Q.nbind albums.save, albums

createIndexes = ->
  Q.all [
    ensureIndexOnAlbums({path: 1}, {unique: true})
    ensureIndexOnAlbums({'pictures.path': 1}, {unique: true, sparse: true})
  ]

# Projections
albumsUserVisible =
  path: true
  title: true
  thumbnail: true
  subalbums: true
  pictures: true

module.exports = {albums, createIndexes, dropAlbums, getAlbum, saveAlbum, albumsUserVisible}