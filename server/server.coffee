path = require 'path'

_ = require 'underscore'

connect = require 'connect'
express = require 'express'

config = require '../server_config.json'
require './db'

{getAlbum} = require './services/album_service.coffee'

staticPath = path.resolve path.dirname(module.filename), '..', 'public'
indexHtml = path.resolve staticPath, 'index.html'

respondJSON = (res, code, data) ->
  res.contentType 'application/json'
  res.send code, JSON.stringify data

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

app.get /^\/v2\/tags$/, (req, res) -> # TODO

app.get /^\/v2\/tags\/[a-zA-Z0-9-\/]+$/, (req, res) -> # TODO

app.get /^\/v2(\/[a-zA-Z0-9-\/]*)$/, (req, res) ->
  path = req.params[0]
  console.log 'album', path
  getAlbum(path).then (album) ->
    respondJSON res, 200, album.toObject()
  .done()

if require.main is module
  app.listen config.port, config.host
