mysql = require 'mysql'
Q = require 'q'
_ = require 'underscore'
path = require 'path'

{albums} = require '../server/db.coffee'

getAlbum = Q.nbind albums.findOne, albums
saveAlbum = Q.nbind albums.save, albums

connection = mysql.createConnection
  host: 'localhost'
  user: 'username'
  database: 'database'
  password: 'secret'
  insecureAuth: true

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
    query("SET NAMES 'latin1';").then ->
      convertSubcategories(0, root, 0).then ->
        saveAlbum root

indented = (indent, args...) ->
  indentation = new Array(indent + 1).join('  ')
  console?.log indentation, args...

indented = ->

sanitizeFilename = (filename) ->
  [filename] = filename.split '.', 1
  filename.replace /[^a-zA-Z0-9-]/g, ''

convertSubcategories = (categoryId, parent, indent=0) ->
  breadcrumb = makeBreadcrumb parent

  # get root category
  query('SELECT cid, name, description FROM cpg11d_categories WHERE parent = ? ORDER BY pos', [categoryId]).spread (categories) ->
    Q.all categories.map (coppermineCategory) ->
      indented indent, "Processing category #{coppermineCategory.name}"

      edegalAlbum =
        path: path.join(parent.path, "category#{coppermineCategory.cid}")
        breadcrumb: breadcrumb
        thumbnail: 'TODO'
        title: coppermineCategory.name
        description: coppermineCategory.description
        subalbums: []
        pictures: []

      parent.subalbums.push _.pick edegalAlbum, 'path', 'title', 'thumbnail'

      albumWork = [
        convertSubcategories(coppermineCategory.cid, edegalAlbum, indent + 1),
        convertAlbums(coppermineCategory.cid, edegalAlbum, indent + 1)
      ]

      Q.all(albumWork).then -> saveAlbum(edegalAlbum)

convertAlbums = (categoryId, parent, indent=0) ->
  breadcrumb = makeBreadcrumb parent

  query('SELECT aid, title, description FROM cpg11d_albums WHERE category = ? ORDER BY pos', [categoryId]).spread (albums) ->
    Q.all albums.map (coppermineAlbum) ->
      indented indent, "Processing album '#{coppermineAlbum.title}'"
      edegalAlbum =
        path: path.join(parent.path, "album#{coppermineAlbum.aid}")
        breadcrumb: breadcrumb
        thumbnail: 'TODO'
        title: coppermineAlbum.title
        description: coppermineAlbum.description
        subalbums: []
        pictures: []

      parent.subalbums.push _.pick edegalAlbum, 'path', 'title', 'thumbnail'
      convertPictures(coppermineAlbum.aid, edegalAlbum, indent + 1).then -> saveAlbum(edegalAlbum)

convertPictures = (albumId, parent, indent=0) ->
  query('SELECT pid, filename, filepath, title, caption FROM cpg11d_pictures WHERE aid = ? ORDER BY position', [albumId]).spread (pictures) ->
    pictures.map (copperminePicture) ->
      title = copperminePicture.title or copperminePicture.filename
      indented indent, "Processing picture '#{title}'"
      parent.pictures.push
        path: path.join(parent.path, sanitizeFilename(copperminePicture.filename) or "picture#{copperminePicture.pid}")
        title: title
        description: copperminePicture.description
        thumbnail: 'TODO'
        media: [ TODO: true ]

if require.main is module
  convertCoppermine().then ->
    process.exit()
  .done()