$ = require 'jquery'
window.Backbone = Backbone = require 'backbone' # XXX

{Album, albums} = require './models/album.coffee'
{AlbumView} = require './views/album_view.coffee'
{PictureView} = require './views/picture_view.coffee'
{getContent} = require './helpers/content_helper.coffee'

class Router extends Backbone.Router
  initialize: ->
    @route /^([\/a-zA-Z0-9-\/]*)$/, 'content'
    @route 'user', 'user'
    @route 'user/:user', 'user'

  user: (user) ->
    console?.log 'route:user'

  content: (path='') ->
    path = '/' + path
    getContent(path).then (results) ->
      {album, picture} = results
      view = albumView = new AlbumView model: album

      if picture
        view = pictureView = new PictureView model: picture, parentView: albumView

      view.render()

$ ->
  router = new Router

  $(document).on 'click', 'a, area', (event) ->
    event.preventDefault()
    href = $(this).attr 'href'
    router.navigate href, trigger: true
    return false

  Backbone.history.start pushState: true
