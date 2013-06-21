Mongolian = require 'mongolian'
server = new Mongolian
db = server.db 'edegal'
albums = db.collection 'albums'

# Indexes
albums.ensureIndex {path: 1}, {unique: true}
albums.ensureIndex {'pictures.path': 1}, {unique: true, sparse: true}

# Projections
albumsUserVisible =
  path: true
  title: true
  thumbnail: true
  subalbums: true
  pictures: true

module.exports = {albums, albumsUserVisible}