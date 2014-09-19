_          = require 'lodash'
path       = require 'path'
express    = require 'express'
config     = require './config'
{getAlbum} = require './services/album_service.coffee'
unusedConn = require './db'

staticPath = config.paths.root
indexHtml  = path.resolve staticPath, 'index.html'

respondModel = (res, model) ->
  return respond404 res unless model
  respondJSON res, 200, _.omit(model.toObject(), '_id')

respondJSON = (res, code, data) ->
  res.contentType 'application/json'
  res.send code, JSON.stringify data

respond404 = (res) ->
  respondJSON res, 404,
    error: 404
    message: 'Not found'

respond500 = (res) ->
  respondJSON res, 500,
    error: 500
    message: 'Internal server error'

indexHtmlAnyway = (req, res, next) ->
  if req.accepts 'html'
    res.sendfile indexHtml
  else
    next()

exports.app = app = express()
exports.router = router = express.Router()

app.use router
app.use express.static(staticPath, maxAge: 24*60*60*1000)
app.use indexHtmlAnyway
app.use respond404

router.get /^\/v2\/tags$/, (req, res) -> # TODO

router.get /^\/v2\/tags\/[a-zA-Z0-9-\/]+$/, (req, res) -> # TODO

router.get /^\/v2(\/[a-zA-Z0-9-\/]*)$/, (req, res) ->
  path = req.params[0]
  console.log 'album', path
  getAlbum(path).then (album) ->
    respondModel res, album
  .fail (e) ->
    console?.error e
    respond500 res

if require.main is module
  app.listen config.port, config.host
