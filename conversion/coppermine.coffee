mysql = require 'mysql'
Q = require 'q'
_ = require 'underscore'
path = require 'path'

originalSlugify = require 'slug'
originalSlugify.charmap['.'] = '-'
originalSlugify.charmap['_'] = '-'

{albums, createIndexes, dropAlbums, getAlbum, saveAlbum} = require '../server/db.coffee'

connection = mysql.createConnection
  host: 'localhost'
  port: 10000
  user: 'coppermine'
  database: 'coppermine'
  password: 'secret'
  insecureAuth: true

PLACEHOLDER_IMAGE = '/images/example_content_360x240.jpg'

root =
  path: '/'
  title: 'Anikin kuva-arkisto'
  breadcrumb: []
  subalbums: []
  pictures: []

connection.connect()

query = Q.nbind connection.query, connection

makeBreadcrumb = (parent) ->
  breadcrumb = parent.breadcrumb ? []
  breadcrumb = breadcrumb.concat [
    path: parent.path
    title: parent.title
  ]

setThumbnail = (album) ->
  album.thumbnail = 
    album.thumbnail ?
    _.first(album.pictures)?.thumbnail ?
    _.first(album.subalbums)?.thumbnail ?
    PLACEHOLDER_IMAGE

convertCoppermine = ->
  Q.all([
    dropAlbums().fail(-> null)
    query("SET NAMES 'latin1';")
  ]).then ->
    convertSubcategories(0, root, 0)
  .then ->
    setThumbnail root
    saveAlbum root
  .then(createIndexes)

indented = (indent, args...) ->
  indentation = new Array(indent + 1).join('  ')
  console?.log indentation, args...

indented = ->

slugify = (str) -> originalSlugify(str).toLowerCase()

sanitizeFilename = (filename) ->
  [filename] = filename.split '.', 1
  slugify(filename) or _.uniqueId('picture')

convertSubcategories = (categoryId, parent, indent=0) ->
  breadcrumb = makeBreadcrumb parent

  # get root category
  query('SELECT cid, name, description FROM cpg11d_categories WHERE parent = ? ORDER BY pos', [categoryId]).spread (categories) ->
    Q.all categories.map (coppermineCategory) ->
      indented indent, "Processing category #{coppermineCategory.name}"
      slug = slugify(coppermineCategory.name) or "category#{coppermineCategory.cid}"

      edegalAlbum =
        path: path.join(parent.path, slug)
        breadcrumb: breadcrumb
        title: coppermineCategory.name
        description: coppermineCategory.description
        subalbums: []
        pictures: []

      albumWork = [
        convertSubcategories(coppermineCategory.cid, edegalAlbum, indent + 1),
        convertAlbums(coppermineCategory.cid, edegalAlbum, indent + 1)
      ]

      Q.all(albumWork).then ->
        setThumbnail edegalAlbum
        parent.subalbums.push _.pick edegalAlbum, 'path', 'title', 'thumbnail'
        saveAlbum(edegalAlbum)

convertAlbums = (categoryId, parent, indent=0) ->
  breadcrumb = makeBreadcrumb parent

  query('SELECT aid, title, description FROM cpg11d_albums WHERE category = ? ORDER BY pos', [categoryId]).spread (albums) ->
    Q.all albums.map (coppermineAlbum) ->
      indented indent, "Processing album '#{coppermineAlbum.title}'"
      slug = slugify(coppermineAlbum.title) or "album#{coppermineAlbum.aid}"

      edegalAlbum =
        path: path.join(parent.path, slug)
        breadcrumb: breadcrumb
        title: coppermineAlbum.title
        description: coppermineAlbum.description
        subalbums: []
        pictures: []

      convertPictures(coppermineAlbum.aid, edegalAlbum, indent + 1).then ->
        setThumbnail edegalAlbum
        parent.subalbums.push _.pick edegalAlbum, 'path', 'title', 'thumbnail'
        saveAlbum edegalAlbum

convertPictures = (albumId, parent, indent=0) ->
  query('SELECT pid, filename, filepath, title, caption FROM cpg11d_pictures WHERE aid = ? ORDER BY position', [albumId]).spread (pictures) ->
    pictures.map (copperminePicture) ->
      title = copperminePicture.title or copperminePicture.filename
      indented indent, "Processing picture '#{title}'"
      parent.pictures.push
        path: path.join(parent.path, sanitizeFilename(copperminePicture.filename) or "picture#{copperminePicture.pid}")
        title: title
        description: copperminePicture.description
        thumbnail: "http://kuvat.aniki.fi/albums/#{copperminePicture.filepath}/thumb_#{copperminePicture.filename}"
        media: [ TODO: true ]

if require.main is module
  convertCoppermine().then ->
    process.exit()
  .done()