$ = require 'jquery'
window.Backbone = Backbone = require 'backbone' # XXX

{Album, albums} = require './models/album.coffee'
{AlbumView} = require './views/album_view.coffee'
{site} = require './models/site.coffee'
{PictureView} = require './views/picture_view.coffee'
{applyTranslations} = require './views/helpers/i18n_helper.coffee'
{getContent} = require './models/helpers/content_helper.coffee'

albumView = null
pictureView = null

class Router extends Backbone.Router
  initialize: ->
    @route /^([\/a-zA-Z0-9-\/]*)$/, 'content'
    @route 'user', 'user'
    @route 'user/:user', 'user'

    if window.ga?
      @on 'all', ->
        console?.log 'sending pageview'
        window.ga 'send', 'pageview'

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

  applyTranslations()

  $(document).on 'click', 'a, area', (event) ->
    $link = $(this)
    return true if $link.attr 'target'
    event.preventDefault()
    router.navigate $link.attr('href'), trigger: true
    false
  
  albums.once 'add', (album) ->
    if album.get('path') == '/'
      title = album.get('title')
    else
      title = _.first(album.get('breadcrumb') ? [])?.title

    site.set 'title', title if title

  site.on 'change:title', (site) ->
    $('.site-title').text (document.title = site.get 'title')

  Backbone.history.start pushState: true
