mysql = require 'mysql'
Q = require 'q'
Q.longStackSupport = true
_ = require 'underscore'
path = require 'path'
ent = require 'ent'

{albums, dropAlbums, getAlbum, saveAlbum} = require '../server/db'
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
    convertSubcategories(0, root).then ->
      finalizeAlbum root

finalizeAlbum = (edegalAlbum, parent) ->
  setThumbnail edegalAlbum

  if parent? and not _.find(parent.subalbums, (subalbum) -> subalbum.path == edegalAlbum.path)
    parent.subalbums.push _.pick edegalAlbum, 'path', 'title', 'thumbnail', '_pos'

  edegalAlbum.subalbums = _.chain(edegalAlbum.subalbums)
    .sortBy((subalbum) -> subalbum._pos)
    .map((subalbum) -> _.omit(subalbum, '_pos'))
    .value()

  saveAlbum edegalAlbum

decodeEntities = (obj, fields...) ->
  for field in fields
    obj[field] = ent.decode(obj[field] ? '')

fixTitle = (title) ->
  title.replace ' - ', ' – '

convertSubcategories = (categoryId, parent) ->
  breadcrumb = makeBreadcrumb parent

  # get root category
  query('SELECT cid, name, description, pos FROM cpg11d_categories WHERE parent = ?', [categoryId]).spread (categories) ->
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
        _pos: coppermineCategory.pos

      processAlbum edegalAlbum, parent: parent, categoryId: coppermineCategory.cid

convertAlbums = (categoryId, parent) ->
  breadcrumb = makeBreadcrumb parent

  query('SELECT aid, title, description, pos FROM cpg11d_albums WHERE category = ?', [categoryId]).spread (albums) ->
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
        _pos: coppermineAlbum.pos

      processAlbum edegalAlbum, parent: parent, albumId: coppermineAlbum.aid

processAlbum = (edegalAlbum, opts) ->
  {albumId, categoryId, parent} = opts

  getAlbum(edegalAlbum.path).then (existingAlbum) ->
    if existingAlbum?
      process.stdout.write '-'
      edegalAlbum = existingAlbum
    else
      process.stdout.write '.'

    work = []
    work.push convertSubcategories(categoryId, edegalAlbum) if categoryId?
    work.push convertAlbums(categoryId, edegalAlbum) if categoryId?
    work.push convertPictures(albumId, edegalAlbum) if albumId? and not existingAlbum?
    return null if _.isEmpty work

    Q.all(work)
  .then ->
    finalizeAlbum edegalAlbum, parent
  .then ->
    edegalAlbum


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


cleanupAlbum = (album) ->
  delete album._pos

if require.main is module
  convertCoppermine().then ->
    walkAlbumsDepthFirst cleanupAlbum
  .then ->
    process.exit()
  .done()
