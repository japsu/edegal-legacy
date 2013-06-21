_ = require 'lodash'

express = require 'express'

{albums, albumsUserVisible} = require './db'

exports.app = app = express()
app.use app.router

respondJSON = (res, code, data) ->
  res.contentType 'application/json'
  res.send code, JSON.stringify data

respondFromDb = (res, collection, query, projection) ->
  collection.findOne query, projection, (err, result) ->
    if result?
      respondJSON res, 200, _.omit(result, '_id')
    else
      respondJSON res, 404,
        status: 404
        message: 'Not found'

albumQuery = (path) ->
  $or: [
    { path },
    { 'pictures.path': path }
  ]

app.get /^\/v2(\/[\/a-zA-Z0-9-\/]*)$/, (req, res) ->
  path = req.params[0]
  console.log 'album', path
  respondFromDb res, albums, albumQuery path, albumsUserVisible

if require.main is module
  app.listen 3000