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

  user: (user) ->
    console?.log 'route:user'

  content: (path='') ->
    path = '/' + path
    getContent(path).then (results) ->
      {album, picture} = results

      if picture
        pictureView.setModel(picture).render()
        window.ga 'send', 'event', 'picture', 'view', path, page: path if window.ga?
      else
        albumView.setModel(album).render()
        window.ga 'send', 'event', 'album', 'view', path, page: path if window.ga?

      window.ga 'send', 'pageview', path if window.ga?


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
