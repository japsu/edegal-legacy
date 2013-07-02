path = require 'path'

_ = require 'underscore'
Q = require 'q'

connect = require 'connect'
express = require 'express'

{albums, albumsUserVisible, getAlbum, getTag, getPicturesTagged} = require './db'

staticPath = path.resolve path.dirname(module.filename), '..', 'public'
indexHtml = path.resolve staticPath, 'index.html'

respondJSON = (res, code, data) ->
  res.contentType 'application/json'
  res.send code, JSON.stringify data

respondFromDb = (req, res, collection, query, projection) ->
  collection.findOne query, projection, (err, result) ->
    if result?
      respondJSON res, 200, _.omit(result, '_id')
    else
      respond404 req, res

respond404 = (req, res) ->
  if req.accepts 'json'
    respondJSON res, 404,
      error: 404
      message: 'Not found'

  else
    res.send 404, 'Not found'

indexHtmlAnyway = (req, res, next) ->
  if req.accepts 'html'
    res.sendfile indexHtml
  else
    next()

albumQuery = (path) ->
  $or: [
    { path },
    { 'pictures.path': path }
  ]

exports.app = app = express()
#app.use connect.compress()
app.use app.router
app.use express.static(staticPath, maxAge: 24*60*60*1000)
app.use indexHtmlAnyway
app.use respond404

app.get '/v2/tags', (req, res) ->

app.get /^\/v2\/tagged\/([a-z0-9-]+)$/, (req, res) ->
  tag = req.params[0]
  console.log 'tag', tag
  Q.all([
    getPicturesTagged(tag)
    getTag(tag: tag)
    getAlbum('/')
  ]).then (picturezy, tagInfo, rootAlbum) ->
    respondJSON
      title: "Tagged: #{tag}" # TODO I18N
      tag: tagInfo,
      path: "/tagged/#{tag}"
      breadcrumb: [
        path: rootAlbum.path # '/'
        title: rootAlbum.title
      ]
      pictures: picturezy.pictures


app.get /^\/v2(\/[a-zA-Z0-9-\/]*)$/, (req, res) ->
  path = req.params[0]
  console.log 'album', path
  respondFromDb req, res, albums, albumQuery path, albumsUserVisible


if require.main is module
  app.listen 3000