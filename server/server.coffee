express = require 'express'
_ = require 'underscore'
{Server, Db} = require 'mongodb'

exports.app = app = express()

server = new Server 'localhost', 27017
db = new Db 'edegal', server, safe: true

respondFromDb = (res, collection, query, fields...) ->
  db.collection(collection).findOne query, (err, result) ->
    if result?
      res.contentType 'application/json'
      res.send JSON.stringify _.pick result, fields...
    else
      res.contentType 'application/json'
      res.send 404, JSON.stringify
        status: 404
        message: "Not found"

app.get '/v1/', (req, res) ->
  respondFromDb res, 'sites', {}, 'title', 'categories'

app.get '/v1/:category', (req, res) ->
  {category} = req.params
  respondFromDb res, 'categories', {category}, 'category', 'title', 'thumbnail', 'albums'

app.get '/v1/:category/:album', (req, res) ->
  {category, album} = req.params
  respondFromDb res, 'albums', {category, album}, 'category', 'album', 'title', 'thumbnail', 'photos'

if require.main is module
  db.open ->
    app.listen 3000