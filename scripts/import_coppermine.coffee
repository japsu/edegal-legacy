mysql = require 'mysql'
Q = require 'q'
_ = require 'underscore'
path = require 'path'
ent = require 'ent'

{albums, createIndexes, dropAlbums, getAlbum, saveAlbum} = require '../server/db'
{slugify, makeBreadcrumb, sanitizeFilename} = require '../shared/helpers/path_helper'
{setThumbnail} = require '../shared/helpers/media_helper'

connection = mysql.createConnection
  host: 'localhost'
  port: 10000
  user: 'b2_coppermine'
  database: 'b2_coppermine'
  password: 'secret'
  insecureAuth: true

CATEGORY_BLACKLIST = [
  1 # User galleries
  107 # Animeunioni
]

connection.connect()

query = Q.nbind connection.query, connection

convertCoppermine = ->
  Q.all([
    getAlbum('/')
    query("SET NAMES 'latin1';")
  ]).spread (root) ->
    convertSubcategories 0, root
  .then ->
    setThumbnail root
    saveAlbum root
  .then(createIndexes)

decodeEntities = (obj, fields...) ->
  for field in fields
    obj[field] = ent.decode(obj[field] ? '')

fixTitle = (title) ->
  title.replace ' - ', ' – '

convertSubcategories = (categoryId, parent) ->
  breadcrumb = makeBreadcrumb parent

  # get root category
  query('SELECT cid, name, description FROM cpg11d_categories WHERE parent = ? ORDER BY pos DESC', [categoryId]).spread (categories) ->
    Q.all categories.map (coppermineCategory) ->
      return null if coppermineCategory.cid in CATEGORY_BLACKLIST

      decodeEntities coppermineCategory, 'name', 'description'
      slug = slugify(coppermineCategory.name) or "category-#{coppermineCategory.cid}"

      edegalAlbum =
        path: path.join(parent.path, slug)
        breadcrumb: breadcrumb
        title: coppermineCategory.name
        description: coppermineCategory.description
        subalbums: []
        pictures: []

      processAlbum edegalAlbum, parent: parent, categoryId: coppermineCategory.cid

convertAlbums = (categoryId, parent) ->
  breadcrumb = makeBreadcrumb parent

  query('SELECT aid, title, description FROM cpg11d_albums WHERE category = ? ORDER BY pos DESC', [categoryId]).spread (albums) ->
    Q.all albums.map (coppermineAlbum) ->
      decodeEntities coppermineAlbum, 'title', 'description'
      slug = slugify(coppermineAlbum.title) or "album-#{coppermineAlbum.aid}"

      edegalAlbum =
        path: path.join(parent.path, slug)
        breadcrumb: breadcrumb
        title: fixTitle(coppermineAlbum.title ? '')
        description: coppermineAlbum.description
        subalbums: []
        pictures: []

      processAlbum edegalAlbum, parent: parent, albumId: coppermineAlbum.aid

processAlbum = (edegalAlbum, opts) ->
  console?.log 'processAlbum', edegalAlbum, opts
  {albumId, categoryId, parent} = opts

  getAlbum(edegalAlbum.path).then (existingAlbum) ->
    edegalAlbum = existingAlbum if existingAlbum?

    work = []
    work.push convertSubcategories(categoryId, edegalAlbum) if categoryId
    work.push convertAlbums(categoryId, edegalAlbum) if categoryId
    work.push convertPictures(albumId, edegalAlbum) if albumId and not existingAlbum?
    Q.all(work).then ->
      setThumbnail edegalAlbum

      unless _.find(parent.subalbums, (subalbum) -> subalbum.path == edegalAlbum.path)
        parent.subalbums.unshift _.pick edegalAlbum, 'path', 'title', 'thumbnail'

      saveAlbum edegalAlbum

      if existingAlbum
        process.stdout.write '-'
      else
        process.stdout.write '.'

convertPictures = (albumId, parent) ->
  query('SELECT pid, filename, filepath, title, caption FROM cpg11d_pictures WHERE aid = ? ORDER BY filename', [albumId]).spread (pictures) ->
    pictures.map (copperminePicture) ->
      decodeEntities copperminePicture, 'title', 'caption'
      title = copperminePicture.title or copperminePicture.filename
      parent.pictures.push
        path: path.join(parent.path, sanitizeFilename(copperminePicture.filename) or "picture-#{copperminePicture.pid}")
        title: fixTitle(title ? '')
        description: copperminePicture.caption ? ''
        media: [ 
          {
            src: "/albums/#{copperminePicture.filepath}#{copperminePicture.filename}",
            width: 6000 # TODO
            height: 4000 # TODO
            original: true
          }
        ]

if require.main is module
  convertCoppermine().then ->
    process.exit()
  .done()
