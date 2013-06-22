$ = require 'jquery'
window.Backbone = Backbone = require 'backbone' # XXX

{Album, albums} = require './models/album.coffee'
{AlbumView} = require './views/album_view.coffee'
{PictureView} = require './views/picture_view.coffee'
{getContent} = require './models/helpers/content_helper.coffee'

albumView = null
pictureView = null

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

      if picture
        pictureView.setModel(picture).render()
      else
        albumView.setModel(album).render()
    .done()

$ ->
  albumView = new AlbumView
  pictureView = new PictureView

  router = new Router

  $(document).on 'click', 'a, area', (event) ->
    event.preventDefault()
    href = $(this).attr 'href'
    router.navigate href, trigger: true
    return false

  Backbone.history.start pushState: true
