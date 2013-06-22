mysql = require 'mysql'
Q = require 'q'

{albums} = require '../server/db.coffee'

getAlbum = Q.nbind albums.findOne, albums
saveAlbum = Q.nbind albums.save, albums

connection = mysql.createConnection
  host: 'localhost'
  user: 'username'
  password: 'secret'

connection.connect()

query = Q.nbind connection.query, connection

makeBreadcrumb = (parent) ->
  breadcrumb = parent.breadcrumb ? []
  breadcrumb = breadcrumb.concat [
    path: parent.path
    title: parent.title
  ]

convertCoppermine = ->
  getAlbum(path: '/').then (root) ->
    convertCategory(0, root)
  .then ->
    saveAlbum root
  .done()

convertSubcategories = (categoryId, parent) ->
  breadcrumb = makeBreadcrumb parent

  # get root category
  query('SELECT cid, name, description FROM cpg11d_categories WHERE parent = ? ORDER BY pos', [categoryId]).then (categories) ->
    Q.all categories.map (coppermineCategory) ->
      edegalAlbum =
        path: "#{parent.path}/category#{coppermineCategory.cid}"
        breadcrumb: breadcrumb
        thumbnail: 'TODO'
        title: coppermineCategory.name
        description: coppermineCategory.description
        subalbums: []
        pictures: []

      parent.subalbums.push _.pick edegalAlbum, 'path', 'title', 'thumbnail'

      albumWork = [
        convertSubcategories(coppermineCategory.cid, edegalAlbum),
        convertAlbums(coppermineCategory.cid, edegalAlbum)
      ]

      Q.all(albumWork).then -> saveAlbum(edegalAlbum)

convertAlbums = (categoryId, parent) ->
  breadcrumb = makeBreadcrumb parent

  query('SELECT aid, title, description FROM cpg11d_albums WHERE category = ? ORDER BY pos', [categoryId]).then (albums) ->
    Q.all albums.map (coppermineAlbum) ->
      edegalAlbum =
        path: "#{parent.path}/album#{coppermineAlbum.aid}"
        breadcrumb: breadcrumb
        thumbnail: 'TODO'
        title: coppermineAlbum.title
        description: coppermineAlbum.description
        subalbums: []
        pictures: []

      parent.subalbums.push _.pick edegalAlbum, 'path', 'title', 'thumbnail'
      convertPictures(coppermineAlbum.aid, edegalAlbum).then -> saveAlbum(edegalAlbum)

convertPictures = (albumId, parent) ->
  query('SELECT filename, filepath, title, caption FROM cpg11d_pictures WHERE album = ? ORDER BY position', [albumId]).then (pictures) ->
    pictures.map (copperminePicture) ->
      parent.pictures.push
        path: "#{parent.path}/picture#{copperminePicture.pid}"
        title: copperminePicture.title
        description: copperminePicture.description
        thumbnail: 'TODO'
        media: [ TODO: true ]
        