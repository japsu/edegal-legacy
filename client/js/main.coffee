$ = require 'jquery'
Backbone = require 'backbone'
require 'transparency'

{Album, albums} = require './models/album.coffee'
{AlbumView} = require './views/album_view.coffee'
{PictureView} = require './views/picture_view.coffee'

class Router extends Backbone.Router
  initialize: ->
    @route /^([\/a-zA-Z0-9-\/]*)$/, 'content'
    @route 'user', 'user'
    @route 'user/:user', 'user'

  user: (user) ->
    console?.log 'route:user'

  content: (path='') ->
    path = '/' + path
    console?.log 'route:content', path
    album = new Album path: path
    album.fetch().then ->
      albums.add album
      view = albumView = new AlbumView model: album

      unless album.get('path') == path
        picture = album.pictures.findWhere path: path
        view = pictureView = new PictureView model: picture, parentView: albumView

      view.render()

$ ->
  router = new Router
  Backbone.history.start pushState: true
